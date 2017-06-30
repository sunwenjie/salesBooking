class Client < Base

  establish_connection "xmo_production".to_sym

  include Concerns::Extract

  include Concerns::Condition

  include Concerns::SendOrderClient

  include Concerns::SerialNumber

  has_and_belongs_to_many :groups, join_table: "#{SendMenu::DbConnection}.client_groups"

  has_many :orders, inverse_of: :client

  has_many :share_clients, inverse_of: :client
  accepts_nested_attributes_for :share_clients, allow_destroy: true

  has_many :examinations,->{order(created_at: :asc)}, inverse_of: :client, as: :examinable do
    def find_examinations_by_node(node_id)
      where({node_id: node_id})
    end
  end

  has_many :client_contacts, inverse_of: :client

  belongs_to :client_channel, :class => Channel, :foreign_key => "channel"

  belongs_to :industry

  belongs_to :currency

  belongs_to :user, inverse_of: :clients


  validates :clientname, presence: true

  validates :brand, presence: true

  validates :clientcontact, presence: true

  validates :linkman_position, presence: true

  validates :clientphone, presence: true

  # validates :created_user, presence: true
  validates :industry_id, presence: true

  validate :name_and_brand, if: :need_validate

  # soft deleted
  acts_as_paranoid

  after_create :update_client_code


  def approver
    return nil if @approver.nil?
    u = User.find_by(User.user_conditions(@approver))
  end

  #审批者

  def approver=(user)
    u = User.find_by(User.user_conditions(user))
    #throw "approver does not exist"  if u.nil?
    @approver = u
  end

  def need_validate
    self.state == 'unapproved' || self.state == 'cli_saved'
  end

  def name_and_brand
    num = self.new_record? ? 0 : 1
    unless self.clientname.blank? && self.brand.blank?
      if Client.where("whether_channel = 0 and state not in ('released','cli_rejected') and clientname = ? and brand = ? ", self.clientname, self.brand).size > num
        errors.add(:name_and_brand, I18n.t("clients.name_and_brand"))
      elsif Client.where("whether_channel = 1 and state not in ('released','cli_rejected') and  clientname = ? and brand = ? and channel = ?", self.clientname, self.brand, self.channel_id).size > num
        errors.add(:name_and_brand_channel, I18n.t("clients.name_and_brand_channel"))
      end
    end
  end

  def validate_share_clients
    errors.add(:share_client_blank, I18n.t("clients.form.client_blank")) if self.share_clients.blank?
  end

  add_search_scope :in_all do |words|
    like_any([:clientname, :clientcontact, :clientphone], prepare_words(words))
  end

  def self.simple_scopes
    [
        :ascend_by_updated_at,
        :descend_by_updated_at,
        :ascend_by_clientname,
        :descend_by_clientname
    ]
  end

  add_simple_scopes simple_scopes

  add_search_scope :with_group do |group|
    includes(:groups).where(group_conditions(group))
  end

  add_search_scope :with_order_client_share do |order|
    user = User.find_by(user_conditions(order.user_id))
    client = Client.find_by(client_conditions(order.client_id))
    where("#{Client.table_name}.id in (select id from xmo.clients where created_user!='#{user.name}' and state = 'approved' and xmo.clients.brand = '#{client.brand}' and xmo.clients.clientname = '#{client.clientname}' )").
        uniq
  end

  #与订单的客户在同一渠道的销售
  add_search_scope :with_client_same_channel_user do |order, current_user|
    client = Client.find_by(client_conditions(order.client_id))
    user = User.with_client_same_channel(client.channel).map(&:id).uniq
  end

  # def time_released?
  #   (self.created_at < Time.now - 90.day) and (self.orders == []) and (self.state == 'approved')
  # end

  def channel_name
    client_channel.present? ? self.client_channel.channel_name : ""
  end

  def channel_id
    client_channel.present? ? self.client_channel.id : ""
  end

  def industry_name
    industry_id.present? ? (Industry.find industry_id).name : ""
  end

  def whether_cross_district?
    self.whether_cross_district == true
  end

  #更新广告主的code字段
  def update_client_code
    client = (self.class == Client) ? self : self.client
    new_code = 'AL' + "%09d" % client.id
    client.update_columns({:code => new_code})
  end


  #根据当前提交审批状态匹配当前客户state
  def state_by_approval_or_cross_approval(approval_status, client_status)
    whether_cross_district = self.whether_cross_district?
    if client_status.present?
      if whether_cross_district
        approval, from_state, to_state, color_class = cross_approval_state(approval_status, client_status)
      else
        approval, from_state, to_state, color_class = approval_state(approval_status)
      end
    end
    return approval, from_state, to_state,  color_class
  end

  #UI客户提交审批
  def deal_client_approval(params,current_user)
    #节点标签
    methodname = params[:nodename]
    node = Node.find_by_actionname(methodname)
    client_state = ''
    state = ''
    #模型
    I18n.locale = params[:local_language].present? ? params[:local_language].to_sym : I18n.locale
    #节点状态
    status = params[:status]
    #是否有当前操作权限? params["node_id"].precent?
    #注意当角色为admin的时候UI上应该全部params["node_id"]都拥有
    if params[:node_id].present? || status == '1'
      comment = params[:comment]
      position = params[:position]
      #当前用户ID
      self.approver = params[:approver].present? ? params[:approver].to_i : current_user
      current_user = self.approver
      client_status = Client.with_sale_clients(current_user.id, self.id).last['status'].split(',') rescue [] #当前客户两个审批流的状态 "0,0"
      client_status = client_status.push('0') if client_status.size == 1 #客户两个流是顺序操作，所以当跨区审批未操作时补0
      approval, from_state, to_state, color_class = self.state_by_approval_or_cross_approval(status, client_status) #客户状态
      p "********:position:#{to_state}"
      self.state = to_state
      approve_message = validate_submit(position)
      return approve_message,status,color_class,client_state,state if approve_message.present?
      state = to_state
      client_state = to_state.present? ? I18n.t("clients.index.#{to_state}") : ''
      # 客户邮件审批申请,客户审批回复邮件
      node_id = status == '1' ? node.id : params[:node_id]
      local_language = params[:local_language].present? ? params[:local_language] : I18n.locale.to_s
      self.send_email(node_id,current_user,local_language,status,approval,comment,from_state,to_state)
    else
      #可以审批该客户的群组
      if params[:common_aproved] == 'unapproved'
        approve_message =  no_cross_client_approval_permission
      else
        approve_message = no_approval_permission
      end
    end
    return approve_message,status,color_class,client_state,state
  end

  def validate_submit(position)
    if !self.save || self.share_clients.blank?
    html = ''
    submit_tip = position == 'client_show_page' ? I18n.t('clients.index.client_commit_tip2') : I18n.t('clients.index.client_commit_tip1', :name => self.clientname, :edit_client_url => "/#{I18n.locale}/clients/#{self.id}/edit?submit_to_edit=true")
    html << %Q(<div id="error_explanation" class="error sticker"><h2 style="font-size:20px;">#{submit_tip}</h2><ul>)
    self.errors.add(:share_client_blank, I18n.t('clients.form.client_blank')) if self.share_clients.blank?
    self.errors.full_messages.each do |msg|
      html << %Q(<li>#{msg}</li>)
    end
    html << %Q(</ul></div>)
    return  html
    end
  end

  # 处理邮件回复审批
  def deal_client_mail_approval(approval, node_id, language)
    last_examination = self.examinations.last
    if (['2', '3'].include? self.current_node_last_status(node_id)) && !(last_examination.from_state == 'unapproved' && last_examination.to_state == 'cross_unapproved' && node_id == 9)
      raise ActiveRecord::RecordNotFound
    else
      from_state,to_state,status,approval = before_approval(approval)
      send_email(node_id,self.approver,language,status,approval,nil,from_state,to_state)
    end
  end

  def send_email(node_id,approver,language,status,approval,comment,from_state,to_state)
    approval_groups = self.approval_groups(6)  if status.to_i == 1 #提交给销售总监审批人
    approval_groups = self.approval_groups(9) if status.to_i == 2 && self.whether_cross_district? && self.state == 'cross_unapproved' #客户支持跨区审批且总监审批通过时
    examination = Examination.examination_create(node_id,approver,self.id,'Client',language,status,approval,comment,from_state,to_state)
    ClientWorker.perform_async(self.id, examination.id, status, approval_groups, language, approver.id)
  end


  #显示所有符合条件的客户
  add_search_scope :with_sale_clients do |user, current_client = nil, date = nil|
    user = User.find_by(user_conditions(user))
    condition = date_range_condition(date)
    where_client = current_client.nil_zero? ? "" : " and m.id = #{current_client}"
    condition += where_client
    return if user.nil?
    if user.administrator?
      find_by_sql(" select m.* from (select
                   c.id,c.clientname as name, c.clientcontact as linkman_name,c.clientemail as email,c.clientphone as linkman_tel,c.created_at,c.updated_at,c.user_id,c.group_id,c.industry_id,c.currency_id,c.company_name,c.brand,c.address,linkman_position,c.whether_cross_district,c.channel,c.whether_channel,c.code,c.state,c.created_user,c.deleted_at,c.status as client_status,
                   channels.channel_name,'6,9' as node_id,ifnull(t3.status,'0,0') as status,ifnull(xmo.currencies.name,'RMB') as currency_name from xmo.clients  c
                   left join
                   (select t2.examinable_id,group_concat(t2.status order by t2.node_id asc) as status from  (select distinct t.examinable_id,t.node_id,t.status from sales_booking_production.examinations t ,
                   (select e.examinable_id,e.node_id,max(e.id)  as maxid from sales_booking_production.examinations e where e.examinable_type = 'Client'
                   group by e.examinable_id,e.node_id)  t1 where t.id = t1.maxid) t2 group by t2.examinable_id) t3
                    on c.id = t3.examinable_id
                   left join sales_booking_production.channels on c.channel = channels.id
                   left join xmo.currencies on c.currency_id = currencies.id
                   where c.deleted_at is null ) m  #{condition} order by m.updated_at desc")
    else
      # channel_ids = user.channel_ids.present? ? user.channel_ids.join(",") : "'no'"
      share_client_id = ShareClient.where("share_id = ?", user.id).map(&:client_id).join(",")
      share_client_id = share_client_id.present? ? share_client_id : "'no'"
      find_by_sql("select distinct m.* from (select t1.id,t1.code,t1.name,t1.state,t1.channel,t1.created_user,t1.brand,t1.linkman_name,t1.linkman_position,t1.linkman_tel,t1.address,t1.created_at,t1.updated_at,t1.whether_cross_district,channels.channel_name,ifnull(t1.node_id,'') as node_id,ifnull(t5.status,'0,0')  as status,  ifnull(xmo.currencies.name,'RMB') as currency_name
                from (select t.id,t.code,t.name,t.state,t.channel,t.created_user,t.brand,t.linkman_name,t.linkman_position,t.linkman_tel,t.address,t.created_at,t.updated_at,t.whether_cross_district,group_concat(t.node_id order by t.node_id asc) as node_id, t.currency_id from
               (select clients.id,clients.code,clients.clientname as name,clients.state,clients.channel,clients.created_user,clients.brand,clients.clientcontact as linkman_name,clients.linkman_position,clients.clientphone as linkman_tel,clients.address,clients.created_at,clients.updated_at,clients.share_id,clients.whether_cross_district,p.node_id as node_id,clients.currency_id from
               (select clients.*,share_clients.share_id from  xmo.clients left join sales_booking_production.share_clients on clients.id = share_clients.client_id)  clients ,
               (select * from  sales_booking_production.permissions where approval_user = '#{user.id}' and model = 'Client') p
               where
               (clients.user_id = p.create_user or clients.share_id = p.create_user)
               and clients.deleted_at is null
                and p.node_id not in(10,11,12,13)
               union all
               select c.id,c.code,c.clientname as name,c.state,c.channel,c.created_user,c.brand,c.clientcontact as linkman_name,c.linkman_position,c.clientphone as linkman_tel,c.address,c.created_at,c.updated_at,'' as share_id,c.whether_cross_district,'' as node_id,c.currency_id from xmo.clients c
               left join sales_booking_production.client_groups on c.id = client_groups.client_id
               left join xmo.groups on client_groups.group_id = xmo.groups.id
               left join xmo.users on c.user_id = xmo.users.id
               left join xmo.users_groups on client_groups.group_id = xmo.users_groups.group_id
               where c.deleted_at is null and
               (c.user_id = '#{user.id}'  or xmo.users_groups.user_id = #{user.id} or c.id in (#{share_client_id}) )
               ) t
               group by t.id,t.code,t.name,t.state,t.channel,t.created_user,t.brand,t.linkman_name,t.linkman_position,t.linkman_tel,t.address,t.created_at,t.updated_at,t.whether_cross_district) t1
               left join
               (select t4.examinable_id,group_concat(t4.status order by t4.node_id asc) as status from  (select t2.examinable_id,t2.node_id,t2.status from sales_booking_production.examinations t2,
               (select e.examinable_id,e.node_id,max(e.id)  as maxid from sales_booking_production.examinations e where e.examinable_type = 'Client'
               group by e.examinable_id,e.node_id)  t3 where t2.id = t3.maxid) t4 group by t4.examinable_id) t5 on t1.id = t5.examinable_id
               left join sales_booking_production.channels on t1.channel = channels.id
               left join xmo.currencies on t1.currency_id = currencies.id
               ) m  #{condition} order by m.updated_at desc
                 ")
    end
  end


  add_search_scope :with_state do |*state|
    where("state in (?)", state)
  end

  add_search_scope :by_message do |message_id|
    joins("left outer join #{SendMenu::DbConnection}.examinations on clients.id = #{SendMenu::DbConnection}.examinations.examinable_id").where("#{Examination.table_name}.message_id = ? and #{Examination.table_name}.examinable_type =?", message_id, 'Client')
  end

  def update_state
    self.update_column(:state, "cli_saved")
  end

  def share_client_user_ids
    self.share_clients.pluck(:share_id)

  end

  def share_client_user
    User.where(User.user_conditions(share_client_user_ids)).eager_load(:agency).map { |x| x.name + " ("+(x.agency.name rescue '')+")" }.join(", ")
  end


  def self.new_client_by_user(params, user)
    client = user.clients.new (params[:client])
    client.created_user = user.name
    client.state = "cli_saved"
    #xmo group_id 和 manage_option 字段不能为空
    client.group_id = 0
    client.manage_option = 'Share'
    client.agency_id = user.agency_id
    business_unit_id = BusinessUnit.where({"agency_id" => user.agency_id}).map(&:id).first
    client.business_unit_id = business_unit_id.nil? ? 1 : business_unit_id
    client.share_clients_attributes = params[:share_client].reduce([]) { |array, e| array << {:share_id => e} } if params[:share_client].present?
    return client
  end

  def save_share_clients(share_client)
    self.share_clients.destroy_all
    share_client.each do |share_id|
      self.share_clients.create share_id: share_id.to_i
    end
  end

  def c_currency_name
    self.currency ? self.currency.name : 'RMB'
  end

  private

  def approval_state(approval_status)
    approval, from_state, to_state, color_class = case approval_status
                                                    when '1' then
                                                      [0,'cli_saved','unapproved','status-submit']
                                                    when '2' then
                                                      [1,'unapproved','approved','status-ready']
                                                    when '3' then
                                                      [0,'unapproved','cli_rejected','status-error']
                                                    when '4' then
                                                      [0,'approved','released','']
                                                  end
  end

  def cross_approval_state(approval_status, current_status)
    manager_approved = current_status[0] == '1'
    case approval_status
      when '1' then
        approval = 0
        from_state = 'cli_saved'
        to_state = 'unapproved'
        color_class = 'status-submit'
      when '2' then
        approval = 1
        from_state = manager_approved ? 'unapproved' : 'cross_unapproved'
        to_state = manager_approved ? 'cross_unapproved' : 'approved'
        color_class = manager_approved ? 'status-submit' : 'status-ready'
      when '3' then
        approval = 0
        from_state = manager_approved ? 'unapproved' : 'cross_unapproved'
        to_state = 'cli_rejected'
        color_class = 'status-error'
      when '4' then
        approval = 0
        from_state = 'approved'
        to_state = 'released'
        color_class = ''
    end
    return approval, from_state, to_state, color_class
  end

  def before_approval(approval)
    old_state = self.state
    if approval
      if self.whether_cross_district?
        if old_state == 'unapproved'
          self.state = 'cross_unapproved'
          from_state = old_state
          to_state = 'cross_unapproved'
        elsif old_state == 'cross_unapproved'
          self.state = 'approved'
          from_state = old_state
          to_state = 'approved'
        end
      else
        self.state = 'approved'
        from_state = old_state
        to_state = 'approved'
      end
      status = 2
      approval = 1
    else
      self.state = 'cli_rejected'
      from_state = old_state
      to_state = 'cli_rejected'
      status = 3
      approval = 0
    end
    self.save
    return from_state,to_state,status,approval
  end

  def no_approval_permission
    %Q(<div id="error_explanation" class="error sticker">#{I18n.t('clients.form.approve_notice')}</div>)
  end

  def no_cross_client_approval_permission
    %Q(<div id="error_explanation" class="error sticker">#{I18n.t('clients.form.approve_notice2')}</div>)
  end

end
