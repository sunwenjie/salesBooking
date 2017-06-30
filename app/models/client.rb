class Client < Base
  establish_connection "xmo_production".to_sym

  include Extract

  include Condition

  include SendOrderAdvertisementClient

  include SerialNumber
  def approver
   return nil if @approver.nil?
   u = User.find_by(User.user_conditions(@approver))
  end #审批者
  
  def approver=(user)
    u = User.find_by(User.user_conditions(user))
    #throw "approver does not exist"  if u.nil?
    @approver = u
  end

  has_many :orders, inverse_of: :client
  has_many :share_clients, inverse_of: :client
  belongs_to :client_channel,:class=>Channel,:foreign_key=>"channel"
  belongs_to :industry
  belongs_to :currency
  # belongs_to :user,inverse_of: :clients,foreign_key: "created_user" ,primary_key:"username"
  belongs_to :user,inverse_of: :clients
  has_and_belongs_to_many :groups, join_table: "#{SendMenu::DbConnection}.client_groups"

  has_many :examinations, inverse_of: :client, as: :examinable

  has_many :client_attribute_values, inverse_of: :client
  has_many :client_contacts,inverse_of: :client
  # CLIENT_STATUS = {"0" =>"客户已保存及等待提交","1" => "客户权限确定中","2"=>"客户权限已确认","3"=>"客户权限未通过"}

  #validates :license, presence: true, uniqueness: true
  validates :clientname, presence: true
  # validates_uniqueness_of :name ,:if => :lock_user?
  validates :brand, presence: true
  validates :clientcontact, presence: true
  validates :linkman_position, presence: true
  validates :clientphone, presence: true
  # validates :created_user, presence: true
  validates :industry_id, presence: true

  validate :name_and_brand,if: :need_validate
  # validate :validate_share_clients
  # soft deleted
  acts_as_paranoid

  after_create :update_client_code

  def lock_records
    Client.joins(:examinations).where(clientname: self.clientname, brand: self.brand, whether_channel: self.whether_channel, examinations: {to_state: 'approved'}).order("examinations.created_at desc")
  end

  def need_validate
    self.state == 'unapproved' || self.state == 'cli_saved'
  end

  def name_and_brand
    num = self.new_record? ? 0 : 1
    unless self.clientname.blank? && self.brand.blank?
    if Client.where("whether_channel = 0 and state not in ('released','cli_rejected') and clientname = ? and brand = ? ",self.clientname,self.brand).size > num
      errors.add(:name_and_brand,I18n.t("clients.name_and_brand"))
    elsif Client.where("whether_channel = 1 and state not in ('released','cli_rejected') and  clientname = ? and brand = ? and channel = ?",self.clientname,self.brand,self.channel_id).size > num
      errors.add(:name_and_brand_channel,I18n.t("clients.name_and_brand_channel"))
    end
    end
  end

  def validate_share_clients
    errors.add(:share_client_blank, I18n.t("clients.form.client_blank")) if self.share_clients.blank?
  end

  add_search_scope :in_all do |words|
    like_any([:clientname,:clientcontact,:clientphone], prepare_words(words))
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
    user =  User.find_by(user_conditions(order.user_id))
    client =  Client.find_by(client_conditions(order.client_id))
    where("#{Client.table_name}.id in (select id from xmo.clients where created_user!='#{user.name}' and state = 'approved' and xmo.clients.brand = '#{client.brand}' and xmo.clients.clientname = '#{client.clientname}' )").
    uniq
  end

  #与订单的客户在同一渠道的销售
  add_search_scope :with_client_same_channel_user do |order,current_user|
    client =  Client.find_by(client_conditions(order.client_id))
    user = User.with_client_same_channel(client.channel).map(&:id).uniq
  end

  # def self.share_clients_for_sale(user)
  #   user =  User.find_by(user_conditions(user))
  #   user_names = [user.username]
  #   sql = ""
  #   user_names.flatten.each{|u| sql += "'#{u}',"}
  #   Client.find_by_sql("
  #     select c.id
  #     from xmo.clients as c
  #     inner join
  #     (select * from xmo.clients where clients.created_user in (#{sql.chop}) and state = 'approved') as a
  #     on c.brand = a.brand and c.clientname = a.clientname
  #     where c.created_user != '#{user.username}' and (c.state = 'approved')
  #   ")
  # end

  
  def time_released?
    (self.created_at < Time.now - 90.day) and (self.orders == []) and (self.state == 'approved')
  end


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
    client.update_columns({:code=>new_code})
  end

  # def have_same_client?
  #   clients = Client.where("clientname = ? and brand = ? and created_user =? and state = ?",self.name,self.brand,self.created_user,"approved")
  #   clients.present? && clients.size > 1
  # end
  
  # def clone_and_release(to_user)
  #   if self.lock_records!=[] && !(self.lock_records.with_state("approved").map(&:created_user).include? to_user.to_s)
  #     self.lock_records.with_state("approved").each do |client|
  #       client.approver = approver
  #       client.release
  #       #---------------clone_client---------------
  #       client_attributes = client.attributes.dup.except('id').except("created_at").except("updated_at")
  #       c_exam_attributes = client.examinations.last.attributes.dup.except('id').except("created_at").except("updated_at").except("created_user")
  #       new_client = Client.new
  #       new_client.attributes = client_attributes
  #       new_client.created_user = to_user
  #       new_client.state = "approved"
  #       new_client.save
  #       c_exam_attributes["examinable_id"] = new_client.id
  #       c_exam_attributes["created_user"] = approver.username
  #       new_client.examinations.create(c_exam_attributes)
  #     end
  #   end
  # end
  #
  # def is_same_group?(user)
  #   group_clients = (user.is?("sale") ? Client.with_user_in_same_groups_include_created_by_self(user) : Client.with_user_in_same_groups_include_created_by_partner(user)).descend_by_updated_at
  #   return true if user.administrator?|| group_clients.include?(self)
  #   same_groups = self.user_group_ids.uniq & user.user_group_ids.uniq
  #   same_groups.length >0
  # end

  #根据当前提交审批状态匹配当前客户state
  def state_by_approval_or_cross_approval(approval_status,client_status)
    p approval_status
    p client_status
    whether_cross_district = self.whether_cross_district?
    if client_status.present?
    if whether_cross_district
      approval,from_state,to_state,color_class = cross_approval_state(approval_status,client_status)
    else
      approval,from_state,to_state,color_class = approval_state(approval_status)
    end
    end
    return approval,from_state,to_state,(color_class.nil? ? "" :color_class)
  end




def approval_state(approval_status)
  if approval_status == "2"
    approval = 1
    from_state =  "unapproved"
    to_state =  "approved"
    color_class = "status-ready"
  elsif approval_status == "1"
    approval = 0
    from_state = "cli_saved"
    to_state = "unapproved"
    color_class = "status-submit"
  elsif approval_status == "3"
    approval = 0
    from_state = "unapproved"
    to_state = "cli_rejected"
    color_class = "status-error"
  elsif approval_status == "4"
    approval = 0
    from_state = "approved"
    to_state = "released"
  end
  return approval,from_state,to_state,color_class
end

def cross_approval_state(approval_status,current_status)
  if approval_status == "2"
    approval = 1
    from_state = current_status[0] == "1" ? "unapproved" : "cross_unapproved"
    to_state = current_status[0] == "1" ? "cross_unapproved" : "approved"
    color_class = current_status[0] == "1" ? "status-submit" : "status-ready"
  elsif approval_status == "1"
    approval = 0
    from_state = "cli_saved"
    to_state = "unapproved"
    color_class = "status-submit"
  elsif approval_status == "3"
    approval = 0
    from_state = current_status[0] == "1" ? "unapproved" : "cross_unapproved"
    to_state =  "cli_rejected"
    color_class = "status-error"
  elsif approval_status == "4"
    approval = 0
    from_state = "approved"
    to_state = "released"
  end
  return approval,from_state,to_state,color_class
end
  # 处理邮件回复审批
  def deal_client_mail_approval(approval,node_id,language)
    old_state = self.state
    if approval

      if self.whether_cross_district?
        if old_state == "unapproved"
          self.state = "cross_unapproved"
          from_state = old_state
          to_state = "cross_unapproved"
        elsif old_state == "cross_unapproved"
          self.state = "approved"
          from_state = old_state
          to_state = "approved"
        end
      else
        self.state = "approved"
        from_state = old_state
        to_state = "approved"
      end
      status = 2
      approval = 1
    else

      self.state = "cli_rejected"
      from_state = old_state
      to_state = "cli_rejected"

      status = 3
      approval = 0
    end

    last_examination = Examination.where({"examinable_id"=> self.id}).last
    if   (["2","3"].include? self.current_node_last_status(node_id)) && !(last_examination.from_state == "unapproved" && last_examination.to_state == "cross_unapproved" && node_id == 9)
      raise ActiveRecord::RecordNotFound
    else

    self.save

    examination = Examination.create :node_id => node_id,
                                     :created_user => self.approver.name,
                                     :status => status,
                                     :approval => approval,
                                     :from_state => from_state,
                                     :to_state => to_state,
                                     :examinable_id => self.id,
                                     :examinable_type => "Client",
                                     :language =>language

    if status == 2 && self.whether_cross_district?   #客户支持跨区审批
      approval_groups = self.approval_groups(9) if self.state == "cross_unapproved" #总监审批通过时
    end

    ClientWorker.perform_async(self.id,examination.id,status,approval_groups,language,self.approver.id)
    end
  end





  #某一个user所在组们关联的所有client,包括(自己创建,而没有分配到自己所在组)的client 
  add_search_scope :with_user_in_same_groups_include_created_by_self do |user|
     user =  User.find_by(user_conditions(user))
     return if user.nil?
     usernames = User.where("id in (?)",User.with_groups(user.user_group_ids)).pluck(:name)
     joins("LEFT OUTER JOIN #{SendMenu::DbConnection}.client_groups ON #{SendMenu::DbConnection}.client_groups.`client_id` = `clients`.`id` ")
     .joins("LEFT OUTER JOIN xmo.groups ON xmo.groups.`id` = #{SendMenu::DbConnection}.client_groups.`group_id` ")
     .joins("LEFT OUTER JOIN xmo.users ON xmo.users.`username` = `clients`.`created_user` ")
     .joins("left join xmo.users_groups on #{SendMenu::DbConnection}.client_groups.group_id = xmo.users_groups.group_id")
     .where("#{Client.table_name}.created_user = ? OR xmo.users_groups.user_id = ? ",user.name,user.id)
     .uniq
  end

  #某一个user所在组们关联的所有client,包括(自己创建,而没有分配到自己所在组)的client,还有同组人创建而没有分配到所在组的client
  add_search_scope :with_user_in_same_groups_include_created_by_partner do |user|
     user =  User.find_by(user_conditions(user))
     return if user.nil?
     usernames = User.where("id in (?)",User.with_groups(user.user_group_ids)).pluck(:name)
     joins("LEFT OUTER JOIN #{SendMenu::DbConnection}.client_groups ON #{SendMenu::DbConnection}.client_groups.`client_id` = `clients`.`id` ")
     .joins("LEFT OUTER JOIN xmo.groups ON xmo.groups.`id` = #{SendMenu::DbConnection}.client_groups.`group_id` ")
     .joins("LEFT OUTER JOIN xmo.users ON xmo.users.`username` = `clients`.`created_user` ")
     .joins("left join xmo.users_groups on #{SendMenu::DbConnection}.client_groups.group_id = xmo.users_groups.group_id")
     .where("#{Client.table_name}.created_user  in (?) OR xmo.users_groups.user_id = ? ",usernames,user.id)
     .uniq
     #where("#{Group.table_name}.id in (?) OR #{Client.table_name}.created_user in (?) ",user.user_group_ids,usernames).uniq
  end

  #某一个user所在的组里所有user创建的client
  add_search_scope :with_created_by_user_in_same_groups do |user|
    user =  User.find_by(user_conditions(user))
    # 同组人的username
    usernames = user.user_group_ids.present? ? User.where("id in (?)",User.with_groups(user.user_group_ids)).pluck(:name) : "nil"
    where("created_user in (?)",usernames).uniq
  end

  #显示所有符合条件的客户
  add_search_scope :with_sale_clients do |user,current_client = nil,date = nil |
    user =  User.find_by(user_conditions(user))
    condition = date_range_condition(date)
    where_client = current_client.nil_zero? ? "" : " and m.id = #{current_client}"
    condition +=  where_client
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
                   where c.deleted_at is null ) m  #{condition} order by m.updated_at desc" )
     else
   # channel_ids = user.channel_ids.present? ? user.channel_ids.join(",") : "'no'"
    share_client_id = ShareClient.where("share_id = ?",user.id).map(&:client_id).join(",")
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

  #共享到某些组中销售的客户
  add_search_scope :with_sale_share_same_groups do |user|
    user =  User.find_by(user_conditions(user))
    joins("LEFT OUTER JOIN #{SendMenu::DbConnection}.client_groups ON #{SendMenu::DbConnection}.client_groups.`client_id` = `clients`.`id` ")
    .joins("LEFT OUTER JOIN xmo.groups ON xmo.groups.`id` = #{SendMenu::DbConnection}.client_groups.`group_id` ")
    .joins("LEFT OUTER JOIN xmo.users ON xmo.users.`username` = `clients`.`created_user` ")
    .joins("left join xmo.users_groups on #{SendMenu::DbConnection}.client_groups.group_id = xmo.users_groups.group_id")
    .where("xmo.users_groups.user_id = ? ",user.id )
  end

  add_search_scope :with_state do |*state|
    where("state in (?)",state)
  end

  add_search_scope :by_message do |message_id|
    joins("left outer join #{SendMenu::DbConnection}.examinations on clients.id = #{SendMenu::DbConnection}.examinations.examinable_id").where("#{Examination.table_name}.message_id = ? and #{Examination.table_name}.examinable_type =?",message_id,'Client')
  end

  def update_state
    self.update_column(:state,"cli_saved")
  end

  def share_client_user_ids
    self.share_clients.pluck(:share_id)

  end

  def share_client_user
    User.where(User.user_conditions(share_client_user_ids)).eager_load(:agency).map{|x| x.name + " ("+(x.agency.name rescue '')+")"}.join(", ")
  end

  def self.get_client_rebate(client_id,start_date=nil,end_date=nil)
    sql = "select distinct re.*,re.rebate from sales_booking_production.orders
           join
           ( select channel_rebates.*,clients.id client_id from xmo.clients join sales_booking_production.channels on clients.channel = channels.id
          join sales_booking_production.channel_rebates on channel_rebates.channel_id  = channels.id
          where channels.is_delete is null or channels.is_delete = ''
           )re
          on orders.client_id = re.client_id
          where orders.client_id = #{client_id}
     "
    sql += " and #{end_date} <= re.end_date" if end_date.present?
    sql += " order by re.end_date asc limit 1"
    all_rebate = Client.find_by_sql("#{sql}") || []
    rebate = all_rebate.present? ? all_rebate.map(&:rebate).join(",").to_i : 0.00
  end




end
