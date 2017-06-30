#encoding: utf-8
class Order < Base

  include Concerns::SerialNumber

  include Concerns::Extract

  include Concerns::Condition

  include Concerns::SendOrderClient

  include Concerns::DealRegions

  serialize :city

  serialize :country

  serialize :delivery

  serialize :third_monitor

  serialize :exclude_date

  serialize :check_download_attr, Hash


  REGIONAL = ["EMPTY", "SPECIAL", "OTHER", "NATION", "US_UK_AU_NZ_MY", "HK_TW_MA_SG", "OTHER_COUNTRY", "SPECIAL_CITY", "SPECIAL_COUNTRY"]

  CHINA_REHIONAL = ["SPECIAL", "OTHER", "NATION", "SPECIAL_CITY"]

  REPORTTEMPLATE = ["standard", "client"]

  REPORTPERIOD = ["daliy", "month", "closure"]

  THIRDMONITOR = ["AdMaster", "other"]

  MAP_CITIES_ID = {"20163" => "1003334", "20184" => "1003591", "20164" => "1003338", "20171" => "1003401", "2344" => "2344", "2446" => "2446", "2158" => "2158"}

  FIRST_TIER_CITY_P = ['1003401', '1003334', '1003338', '20181']
  FIRST_TIER_CITY_C = ['1003401', '1003334', '1003338', '1003571', '1003559']

  NODES = [{1 => ['Pre-sales Approval', '预审']},
           {2 => ['Order Approval','审批']},
           {3 => ['Non-standard Order Approval','特批']},
           {4 => ['Contract Confirmation','合同确认']},
           {5 => ['Operation Assignment','运营分配']}
  ].freeze


  DEFAULTS = {
      :budget_currency => 'RMB',
      :regional => REGIONAL[0],
      :frequency => 6,
      :frequency_limit => true,
      :whether_monitor => false,
      :xmo_code => false,
      :client_material => false,
      :report_template => REPORTTEMPLATE[0],
      :report_period => REPORTPERIOD[0],
      :third_monitor => THIRDMONITOR[0]
  }.freeze

  cattr_accessor :update_user


  # soft deleted
  acts_as_paranoid

  def deleted?
    !!deleted_at
  end

  validates :client_id, presence: true
  #validates :linkman, presence: true

  has_many :advertisements, inverse_of: :order

  has_many :business_opportunity_orders, inverse_of: :order

  has_many :share_orders

  has_many :share_order_groups

  has_many :order_nonuniforms, inverse_of: :order

  accepts_nested_attributes_for :advertisements, :business_opportunity_orders, :share_orders, :share_order_groups, :order_nonuniforms, allow_destroy: true

  has_many :examinations, -> { order(created_at: :asc) }, inverse_of: :order, as: :examinable do
    def find_examinations_by_node(node_id)
      where({node_id: node_id})
    end
  end

  has_many :operations, inverse_of: :order

  belongs_to :client, inverse_of: :orders

  belongs_to :channel

  belongs_to :user, inverse_of: :orders

  belongs_to :industry, inverse_of: :orders


  validates :code, presence: true, uniqueness: true

  validates :regional, presence: true, inclusion: {in: REGIONAL-[REGIONAL[0]]}, if: :whether_executive?

  validates :budget_currency, presence: true

  validates :start_date, date: {on_or_before: :ending_date}, presence: true

  validates :ending_date, presence: true

  validates :budget, presence: true, if: :whether_executive?

  validates :extra_website, presence: true, if: :media_buying?

  validates :linkman, presence: true

  validates :title, presence: true

  validates :title, uniqueness: true, if: :title_is_null?


  validates :interest_crowd, presence: true, if: :andience_buying?

  validate :valid_budget, if: :whether_service?

  validate :valid_delivery_date, if: :whether_nonuniform?

  validate :valid_delivery_budget, if: :whether_nonuniform?

  validates :msa_contract, presence: true, if: :validate_msa?

  validates :business_opportunity_number, presence: true, if: :whether_business_opportunity?

  attr_accessor :advertisement_tatol_budget_radio

  acts_as_list scope: :user

  after_initialize :ensure_attachment

  after_initialize :generate_code

  after_initialize :set_default_value

  before_save :update_order_regional, :update_last_user

  after_create :update_order_code, :update_order_columns, :update_rebate

  after_create :update_order_columns

  %w{schedule proof executer draft}.each do |_|
    eval %Q(
          has_one :#{_},-> { where attachment_type: '#{_.classify}' }, inverse_of: :order, dependent: :destroy, autosave: true

          delegate :attachment, :attachment=, to: :#{_}, prefix: true
       )
  end

  #是否是执行类订单
  def whether_executive?
    self.whether_service == false
  end

  #是否是服务类订单
  def whether_service?
    self.whether_service == true
  end

  #是否是商机订单
  def whether_business_opportunity?
    self.whether_business_opportunity == true
  end

  #是否是匀速投放
  def whether_nonuniform?
    self.whether_nonuniform == false && self.whether_service == false
  end

  #非匀速投放验证
  def valid_delivery_date
    errors.add(:nonuniform_date_range, I18n.t("order.nonuniform_date_range")) if self.order_nonuniforms.blank?
  end

  #订单名称是否为空
  def title_is_null?
    !self.title.blank?
  end

  def valid_delivery_budget
    errors.add(:nonuniform_budget, I18n.t("order.nonuniform_budget")) if self.order_nonuniforms.blank?
  end

  #服务订单预算，服务费，服务费率必填一项验证
  def valid_budget
    errors.add(:budget_service_charges_scale, I18n.t("order.budget_service_charges_scale")) if self.budget.blank? && self.service_charges.blank? && self.service_charges_scale.blank?
  end

  #判断此订单是否需要分量
  def jast_for_gp_advertisement?
    !self.whether_service?
  end

  #此订单环节最后一次操作状态
  def order_approval_node_state(*node_name)
    node_status = []
    node_name.each do |name|
      node_id = case name
                  when 'order_approval' then
                    is_standard ? 3 : 2
                  when 'pre_check' then
                    1
                  when 'contract' then
                    4
                  when 'gp_control' then
                    7
                  else
                    ''
                end
      node_status << self.current_node_last_status(node_id).to_i
    end
    node_status = (node_status.size == 1 || node_status.blank?) ? node_status.first.to_i : node_status
    return node_status
  end

  #订单是否存在并小于40/100(判断发邮件给总裁审批)
  def send_email_to_approve?
    max = self.unstandard_range[1]
    self.gp_check == true && max != 0.0 && self.net_gp.to_f <= max
  end

  def proceed_delete?
    !self.proof_attachment.url
  end


  #克隆advertisement属性
  def clone_ad_attributes
    ad_attributes = []
    self.advertisements.each do |ad|
      ad_attributes << ad.dup.attributes.except('id')
    end
    ad_attributes
  end


  def total_budget_radio_is_100
    advertisements = self.advertisements
    advertisements.present? && advertisements.map(&:budget_ratio_show).inject(0, :+) == self.budget
  end

  def media_buying?
    extra_website.present?
  end

  def andience_buying?
    interest_crowd.present?
  end

  def is_msa?
    self.whether_msa == true
  end

  def validate_msa?
    self.whether_msa == true && self.whether_service == false
  end

  def report_period_show
    self.report_period.split(',') if self.report_period
  end

  def update_last_user_and_last_time(user)
    order_approval_status, contract_status = order_approval_node_state('order_approval', 'contract')
    completed = order_approval_status == 2 && contract_status == 2
    xmo_order_state = (self.xmo_order_state == 'examine_completed' || completed) ? 'examine_completed' : ''
    state = completed ? 'examine_completed' : ''
    self.update_columns(:last_update_user => user, :last_update_time => Time.now, :state => state, :xmo_order_state => xmo_order_state)
  end

  def period
    (ending_date - start_date).to_i - exclude_date.size + 1
  end

  def industry_name
    industry.present? ? (I18n.locale.to_s == "en" ? industry.name : industry.name_cn) : ''
  end

  def generate_schedule
    generator = Generator::ExcelGenerator.new(self)
    generator.generate_schedule
  end

  def generate_executer
    generator = Generator::ExecuterGenerator.new(self)
    generator.generate_executer
  end

  #是否展示第三方监控
  def whether_monitor?
    self.whether_monitor && self.whether_monitor==true
  end

  def nonstandard?
    advertisements.any? { |adv| adv.nonstandard? }
  end

  def underpraise?
    advertisements.any? { |adv| adv.underpraise? }
  end

  def planner_ctr?
    advertisements.any? { |adv| adv.diff_ctr? }
  end


  #当前用户是否可以修改编辑该订单
  def can_edit?(user)
    user_id = user.id
    share_orders = ShareOrder.where({share_id: user_id}).map(&:order_id)
    (self.user_id == user_id) || (share_orders.include? self.id) || user.administrator?
  end

  def current_user_order?(current_user)
    self.user_id == current_user.id
  end

  def other_product?
    advertisements.any? { |adv| adv.other_product? }
  end

  def before_other_ctr?
    advertisements.any? { |adv| adv.before_other_ctr? && adv.ad_type != 'OTHERTYPE' }
  end

  def china_regional?
    %w[SPECIAL OTHER NATION SPECIAL_CITY].include?(self.regional)
  end

  def provinces
    self.delivery_type == '2' ? self.delivery_city_level : self.delivery_province
  end

  def admeasure_miss_100?
    advertisements.all? { |adv| adv.admeasure_miss_100? }
  end

  # def return_gp_result(language =nil)
  #   min, max = self.unstandard_range
  #   gp_rake = self.net_gp.present? ? self.net_gp : 0.0
  #   gp_text = I18n.t("order.form.to_be_improved_immediately2", :locale => (language.present? ? language.to_sym : I18n.locale))
  #   if (gp_rake < min)
  #     gp_text = I18n.t("order.form.to_be_improved_immediately2", :locale => (language.present? ? language.to_sym : I18n.locale))
  #   elsif (min <= gp_rake && gp_rake <= max)
  #     gp_text = I18n.t("order.form.yet_to_improve_gp2", :locale => (language.present? ? language.to_sym : I18n.locale))
  #
  #   elsif (max < gp_rake && gp_rake < 100)
  #     gp_text = I18n.t("order.form.gp_meet_standard2", :locale => (language.present? ? language.to_sym : I18n.locale))
  #   end
  #   return gp_text
  # end


  #订单关键字段改变时触发
  def update_order_examinations_status(origin_order, current_user)
    key1 = origin_order.budget != self.budget
    key2 = (origin_order.free_tag? ? origin_order.free_tag : '0') != self.free_tag
    key3 = origin_order.start_date != self.start_date || origin_order.ending_date != self.ending_date || origin_order.exclude_date.to_a != self.exclude_date.to_a
    key4 = (origin_order.whether_service?) != (self.whether_service?)
    key5 = origin_order.whether_nonuniform != self.whether_nonuniform
    key6 = diff_regions?(origin_order)
    #修改货币单位后更新所有产品折扣
    if origin_order.budget_currency != self.budget_currency
      update_all_ads_discount
    end
    if (key1 || key2 || key3 || key4 || key5 || key6)
      self.change_examinations_status(current_user)
      self.update_columns({:gp_evaluate => nil, :gp_check => false, :net_gp => nil})
      self.update_order_columns
    end
  end

  #订单保存前封装regional
  def update_order_regional
    select_regions = regions_to_json(self.new_regions)
    if select_regions
      country = select_regions[0]['country']
      province = select_regions[0]['province']
      if country == 'china' && !select_regions[1].present?
        select_province = province.map { |p| p['province_id'] } rescue []
        select_city = province.map { |p| p['city_id'] }.join(',').split(',') rescue []
        first_city_level = select_province.all? { |p_id| p_id.in? FIRST_TIER_CITY_P } && select_city.all? { |p_id| p_id.in? FIRST_TIER_CITY_C }
        city_level = select_regions[0]['city_level']
        self.regional = (city_level == '1' && first_city_level) ? 'SPECIAL' : 'OTHER'
      else
        self.regional = 'OTHER_COUNTRY'
      end
    else
      self.regional = 'EMPTY'
    end
  end

  def update_last_user
    update_user = Order.update_user
    self.last_update_user = update_user ? "" : update_user.name rescue self.examinations.last.created_user
    self.last_update_time = Time.now
  end


  #是否为非标订单
  def order_standard_or_unstandard?
    self.send_email_to_approve?
  end

  #手动触发订单完整性验证
  def valid_executive
    self.invalid?
    advertisements = self.advertisements
    if advertisements.present?
      self.errors.add(:advertisement_ad_type, I18n.t('order.form.advertisement_tip3')) if advertisement_category? || advertisement_product?
      self.errors.add(:advertisement_tatol_budget_radio, I18n.t('order.form.budget_tip2')) unless self.total_budget_radio_is_100
      self.errors.add(:advertisement_before_other_ctr, I18n.t('order.form.ctr_tip')) if self.before_other_ctr?
      self.errors.add(:advertisement_admeasure_miss, I18n.t('order.form.budget_tip1')) unless self.admeasure_miss_100?
      self.errors.add(:advertisement_cost, I18n.t('order.form.advertisement_tip4')) if advertisement_cost?
    else
      self.errors.add(:advertisement_num, I18n.t('order.form.advertisement_num'))
    end
    self.errors.add(:share_order_blank, I18n.t('order.form.order_owner_error')) if share_order_user_ids.blank?
    # self.errors.add(:share_order_group_blank, I18n.t("order.form.order_group_error")) unless ShareOrderGroup.find_by_order_id(self.id).present?
  end

  #产品大类是否存在为空
  def advertisement_category?
    advertisements.any? { |ad| !ad.ad_type? }
  end

  #产品小类是否存在为空
  def advertisement_product?
    advertisements.any? { |ad| !ad.product_id? }
  end

  #产品卖价是否存在为空

  def advertisement_cost?
    advertisements.any? { |ad| !ad.cost? }
  end

  #当所有标签都做提交操作时取 当前订单最小最左状态
  #当有标签做审批操作时取当前订单最右状态

  def map_order_status(status, is_non_standart, gp_submit_orders)

    order_status = order_status(status, is_non_standart)
    map_order_flows = [{1 => [I18n.t("order.status.pre_sale_check"), I18n.t("order.status.pre_sale_check_gp"), I18n.t("order.status.pre_sale_check_gp_finish")], 2 => [I18n.t("order.status.pre_sale_checked"), I18n.t("order.status.pre_sale_finish_gp"), I18n.t("order.status.pre_sale_check_gp_checked")], 3 => I18n.t("order.status.pre_sale_unchecked")},
                       {1 => [I18n.t("order.status.approving01"), I18n.t("order.status.approving02")], 2 => I18n.t("order.status.approved"), 3 => I18n.t("order.status.unapproved")},
                       {2 => I18n.t("order.flow.schedule_list_submit")},
                       {1 => I18n.t("order.status.contract_approving"), 2 => I18n.t("order.status.contract_approved"), 3 => I18n.t("order.status.contract_unapproved")},
                       {1 => I18n.t("order.status.am_wait_distribute"), 2 => I18n.t("order.status.am_distributed")}]
    max = order_status.sort.last

    in_process = order_status.include? 1
    if max != 0
      if in_process
        #有环节为提交状态 取最左一个待审批状态
        if is_non_standart && (first_find(order_status, 1) == 1) #非标订单
          map_order_flows[1][1][1]
        elsif !is_non_standart && (first_find(order_status, 1) == 1) #标准订单
          map_order_flows[1][1][0]
        elsif first_find(order_status, 1) == 0
          if self.is_jast_for_gp && !self.whether_service? # 支持gp分配
            if self.is_gp_commit #gp分配为完成
              map_order_flows[0][1][2]
            else
              map_order_flows[0][1][1]
            end
          else
            map_order_flows[0][1][0] #不支持gp分配
          end
        else
          map_order_flows[first_find(order_status, 1)][1]
        end

      else #全部做过审批操作 取最右
        n, m = last_find(order_status)
        if is_non_standart && (n == 1) && (m == 1) #非标订单
          map_order_flows[1][1][1]
        elsif !is_non_standart && (n == 1) && (m == 1) #标准订单
          map_order_flows[1][1][0]
        elsif (n == 0) && (m == 2)
          if self.is_jast_for_gp && !self.whether_service? #支持GP分配单审批通过
            if self.is_gp_commit
              map_order_flows[0][2][2]
            else
              map_order_flows[0][2][1]
            end
          else
            map_order_flows[0][2][0] #不支持GP分配单审批通过
          end
        else
          map_order_flows[n][m]
        end
      end
    elsif max == 0
      if self.is_gp_commit
        I18n.t("order.status.gp_checked")
      else
        if gp_submit_orders.include? self.id
          I18n.t("order.status.gp_in_check")
        else
          I18n.t("order.status.wait_submit")
        end
      end

    end
  end


  def schedule_status
    if proof_state == '0'
      I18n.t('order.flow.schedule_list_submit')
    else
      I18n.t('order.flow.schedule_list_unsubmit')
    end
  end


  # 当前订单排期表操作信息
  def schedule_node_message
    proof_submit = proof_state == '0'
    create_user = schedule_commit_user? && proof_submit ? schedule_commit_user : '-'
    create_time = schedule_commit_time? && proof_submit ? schedule_commit_time.localtime.strftime("%Y/%m/%d %H:%M") : '-'
    return create_user, create_time
  end

  #当前订单是否有地域分配
  def order_have_admeasure_map?
    advertisements.any? { |ad| ad.have_admeasure_map? }
  end


  #获取当前用户当前订单所在运营审批流
  def order_coordinate_groups_users(node_id)
    User.with_groups_name(order_coordinate_groups(node_id)).uniq
  end


  #订单提交与审批处理
  def deal_order_submit_approver(params, current_user)
    #节点标签
    methodname = params['nodename']
    node = Node.find_by_actionname(methodname)
    local_language = I18n.locale.to_s
    node_id = node.id
    operate_node = node_id == 7 ? 6 : node_id
    change_unstandard = false
    change_standard = false
    #节点状态
    status = params[:status]
    #是否有当前操作权限? params["node_id"].precent?
    #注意当角色为admin的时候UI上应该全部params["node_id"]都拥有

    if params['node_id'].present? || status == '1'
      color_class = color_class_by_status(status)
      comment = params[:comment]
      # 邮件审批申请
      nodes = Order::NODES
      node_status = node.id == 7 ? ['GP Estimation', '毛利预估'] : nodes[node_id-1][node_id]
      Order.update_user = current_user
      if status == '1'
        approve_message = validate_order(params[:position]) #订单提交做必填验证
        return approve_message, status, color_class, operate_node, change_unstandard, change_standard if approve_message.present?
        examination = Examination.examination_create(node_id, current_user, self.id, 'Order', local_language, status, '1', comment) # 保存提交审批记录
        send_email_to_approvers(current_user, node_id, examination.id, node_status, local_language) #节点提交给审批人发邮件
      else
        approve_message = validate_order_approval(current_user, params[:node_id]) if [2, 3].include? node_id #审批节点  审批通过时验证GP预估是否提交
        approve_message = validate_contract_approval if node_id == 4 && status == '2' #合同审批 验证排期表是否已经上传
        return approve_message, status, color_class, operate_node, change_unstandard, change_standard if approve_message.present?
        if methodname == 'order_distribution'
          color_class = deal_operate_distribution(params[:operator_id], params[:operation], params[:operation_share_ams], comment)  if params[:operator_id].present? && params[:operation].present?
          self.insert_into_clientgroups
        end
        examination = Examination.examination_create(node_id, current_user, self.id, 'Order', local_language, status, '1', comment) # 保存提交审批记录
        #审批人审批给销售发邮件
        status_change, color_class_change, change_unstandard_change, change_standard_change = send_email_to_sales(current_user, node_id, status, examination.id, node_status, local_language)
        status, color_class, change_unstandard = status_change, color_class_change, change_unstandard_change if status_change.present? && color_class_change.present?
        change_standard = change_standard_change if change_standard_change
      end
    elsif (self.operator_and_share_opertor.include? current_user.id) && node_id == 5
      color_class = deal_operate_distribution(params[:operator_id], params[:operation], params[:operation_share_ams], comment)  if params[:operator_id].present? && params[:operation].present?
    else
      approve_message = no_approval_permission
    end
    return approve_message, status, color_class, operate_node, change_unstandard, change_standard
  end

  #处理订单邮件回复审批
  def deal_order_mail_approval(approval, node_id, language)
    node_status = NODES[node_id-1][node_id] if node_id != 7
    if approval
      status = 2
      approval = 1
    else
      status = 3
      approval = 0
    end
    approver = self.approver
    examination = Examination.new :node_id => node_id,
                                  :created_user => approver.nil? ? 'sales_notification' : approver.name,
                                  :status => status,
                                  :approval => approval,
                                  :examinable_id => self.id,
                                  :examinable_type => 'Order',
                                  :language => language
    if ['2', '3'].include? self.current_node_last_status(node_id)
      raise '已做过审批操作,不能重复审批'
    elsif node_id == 7 && status == 2 #毛利预估通过
      examination.save
      gp_approved(approver, language)
    elsif node_id == 7 && status == 3
      raise '毛利预估审批没有拒绝操作'
    else
      examination.save
      contract_approved(examination.id, language) if node_id == 4 && status == 2 #合同审批通过
      order_approved(approver, language, node_id) if (node_id == 2 || node_id == 3) && status == 2 #订单审批通过
      self.deal_reset_gp(approver, language) if (node_id == 2 || node_id == 3) && status == 3 #订单审批不通过,重置GP状态
      SaleWorker.perform_async(self.id, node_status, status, language, nil, approver.id)
    end
  end

  #GP审批通过
  def gp_approved(approver, language)
    #更新订单操作人信息
    self.update_gp_commit_info(approver)
    order_approval_status = self.order_approval_node_state('order_approval')
    change_standard = false
    if order_approval_status == 3 #重置订单审批节点状态
      self.reset_order_approval(approver)
      change_standard = true
    else #发邮件给大区经理
      self.deal_gp_commit_mail(language)
    end
    return change_standard
  end

  #合同审批通过,给运营分配审批者发邮件
  def contract_approved(examination_id, language)
    approval_groups = self.approval_groups(5)
    oprate_node_status = ['Job Assignment', '运营分配']
    OrderWorker.perform_async(self.id, approval_groups, examination_id, oprate_node_status, 5, language) if approval_groups.present?
    self.set_business_opportunities_process('contract_approval')
  end

  #订单审批通过，更新商机进度为50%
  def order_approved(approver, language, node_id)
    self.set_business_opportunities_process('order_approval')
    if node_id == 2 && self.whether_executive? #大区经理审批
      self.save_gp_check(approver) if self.net_gp.blank?
      status, color_class, change_unstandard = self.deal_region_manager_approval(approver,language) if order_standard_or_unstandard?
    end
  end


  #GP审批通过后发邮件给大区经理
  def deal_gp_commit_mail(language)
    if self.order_approval_node_state('order_approval') == 1
      node_status = ['Order Approval', '审批']
      examination = self.last_examination_by_node(2)
      OrderWorker.perform_async(self.id, self.approval_groups(2), examination.id, node_status, 2, language) if examination
    end
  end

  #更新gp操作人信息
  def update_gp_commit_info(current_user)
    username = current_user ? '' : current_user.name
    time_now = Time.now
    self.update_columns(:gp_commit_user => username, :gp_commit_time => time_now, :last_update_user => username, :last_update_time => time_now, :is_gp_commit => true)
  end

  #GP审核通过后，如果订单审批未通过则重置订单审批节点状态
  def reset_order_approval(current_user)
    change_standard_approval = self.change_examination_some_node_status(2, current_user)
    change_unstandard_approval = self.change_examination_some_node_status(3, current_user)
    if change_standard_approval || change_unstandard_approval
      #更新订单为标准订单
      self.update_columns({:is_standard => false}) if self.is_standard
      self.update_columns({:gp_check => false})
    end
  end

  #排期表提交后邮件发送
  def deal_proof_commit_mail(approval_groups, current_user, language)
    # 保存提交审批记录
    examination_create(8, current_user, language)
    node_status = ['Contract Confirmation', '合同确认']
    examination = self.last_examination_by_node(4)
    OrderWorker.perform_async(self.id, approval_groups, examination.id, node_status, 4, language)
  end

  #大区经理审批通过后,若非标则给特批人发邮件
  def deal_region_manager_approval(approver,local_language)
    examination_special_approval = examination_create(3, approver, local_language)
    update_is_standard = self.update_is_standard
    special_approval_groups = self.approval_groups(3) #特批人
    color_class = 'status-submit'
    change_unstandard = true if update_is_standard
    status = '1'
    #给特批人发邮件
    node_status = ['Non-standard Order Approval', '特批']
    OrderWorker.perform_async(self.id, special_approval_groups, examination_special_approval.id, node_status, 3, local_language) if special_approval_groups.present?
    return status, color_class, change_unstandard
  end

  #更新订单为非标订单
  def update_is_standard
    self.update_columns(:is_standard => true)
  end


  #预审提交发邮件给毛利预估人
  def send_email_to_gp_estimation(current_user, local_language)
    examination = examination_create(7, current_user, local_language)
    gp_approval_groups = self.approval_groups([7]) #（毛利预估人） 参数7表示 毛利预估节点
    gp_status = ['GP Estimation', '毛利预估']
    OrderWorker.perform_async(self.id, gp_approval_groups, examination.id, gp_status, 7, local_language) if gp_approval_groups.present?
  end


  #各节点提交，给审批人发邮件

  def submit_node(nodeid)
    if (nodeid == 2 && self.is_gp_commit == false && self.is_jast_for_gp) || (nodeid == 4 && self.proof_state == "1") #订单审批提交或者合同确认提交
      []
    else
      self.approval_groups(nodeid)
    end
  end


  #订单审批不通过发邮件给毛利预估人
  def deal_reset_gp(current_user, local_language)
    reset_gp = self.change_examination_some_node_status(7, current_user)
    if reset_gp
      self.update_columns({:is_gp_commit => false, :gp_evaluate => nil, :net_gp => nil})
      gp_approval_groups = self.approval_groups([7]) #（毛利预估人） 参数7表示 毛利预估节点
      ResetGpWorker.perform_async(self.id, gp_approval_groups, local_language)
    end
  end


  #保存毛利预估，市推费用，净毛利
  def save_gp_check(current_user, gp_evaluate = nil, rebate = nil, market_cost = nil, net_gp =nil)
    gp_evaluate = gp_evaluate.present? ? gp_evaluate.to_f : self.est_gp
    rebate = rebate.present? ? rebate.to_f : (self.rebate.present? ? self.rebate : 0.0)
    market_cost = market_cost.present? ? market_cost.to_f : default_market_cost
    net_gp = net_gp.present? ? net_gp : (gp_evaluate - rebate - market_cost).round(2)
    self.update_columns(:gp_evaluate => gp_evaluate, :rebate => rebate, :market_cost => market_cost, :net_gp => net_gp, :last_update_user => current_user.present? ? current_user.name : "", :last_update_time => Time.now, :gp_check => true)
  end

  #根据销售bu使用不同市推默认值
  def default_market_cost
    user_ids = self.share_order_user_ids << self.user_id
    bu = User.where({"id" => user_ids.uniq}).pluck(:bu).flatten.uniq rescue []
    default_market_cost = DefaultMarketCost.all.order(order_by: :asc)
    market_cost = 0.00
    current_market_cost = self.market_cost
    if current_market_cost
      market_cost = current_market_cost.to_f
    else
      default_market_cost.each do |d_mark_cost|
        if bu.include? d_mark_cost.bu
          market_cost = d_mark_cost.market_cost
          break
        end
      end
    end
    return market_cost.to_f
  end


  #更新代理返点
  def update_rebate
    rebate = self.get_channel_rebate
    self.update_columns({:rebate => rebate})
  end

  def get_channel_rebate
    sql = "select distinct re.*,re.rebate from orders
           join
           ( select channel_rebates.*,clients.id client_id from xmo.clients join channels on clients.channel = channels.id
          join channel_rebates on channel_rebates.channel_id  = channels.id
          where channels.is_delete is null or channels.is_delete = ''
           )re
          on orders.client_id = re.client_id
          and orders.ending_date <= re.end_date"

    sql += " and orders.id = #{self.id}" if self.id.present?
    sql += " order by re.end_date asc limit 1"
    all_rebate = Order.find_by_sql("#{sql}") || []
    all_rebate.present? && self.id.present? ? all_rebate.first.rebate : 0.00
  end

  #运营分配成功之后更新xmo.clientgroups
  def insert_into_clientgroups
    if self.order_coordinate_groups(5).present?
      client_id = self.client_id
      group_ids = self.order_coordinate_groups(5)
      sql = ActiveRecord::Base.connection()
      agency_ids = Group.where({"id" => group_ids}).map { |group| [group.id.to_s, group.agency_id] }
      group_agency = agency_ids.present? ? agency_ids.flatten.each_slice(2).to_h : {}
      if group_ids.present?
        group_ids.each do |clientgroup|
          client_shared = Client.find_by_sql("select count(*) as num from xmo.clientgroups where client_id = #{client_id} and group_id = #{clientgroup} and group_type = 'SHARED'")
          if client_shared.first["num"] == 0
            sql.insert "insert into xmo.clientgroups(client_id,group_id,created_at,updated_at,group_type) values(#{client_id},#{clientgroup},now(),now(),'SHARED')"
          end
          client_groupshared = Client.find_by_sql("select count(*) as num from xmo.clientgroups where client_id = #{client_id} and group_id = #{clientgroup} and group_type = 'GROUP_SHARED'")
          if client_groupshared.first["num"] == 0
            sql.insert "insert into xmo.clientgroups(client_id,group_id,created_at,updated_at,group_type) values(#{client_id},#{clientgroup},now(),now(),'GROUP_SHARED')"
          end
        end
        sql.update "update xmo.clients set group_ids_extend = '#{group_ids.join(",")}' , manage_option='Share' where id = #{client_id}" if group_agency.present?
      end
    end
  end


  #当前非标订单审批流net gp设定为范围的审批流
  def unstandard_range
    approval_flow_ids = current_flows(3)
    approval_flow = ApprovalFlow.where({"id" => approval_flow_ids, "range_type" => 'range'}).order(:min, :max).first rescue nil
    if approval_flow
      min, max = approval_flow.min, approval_flow.max
    else
      min, max = nil, nil
    end
    return min.to_f, max.to_f
  end

  #当前订单所在审批流包含的运营am组
  def order_coordinate_groups(node_id)
    approval_flow_ids = current_flows(node_id) # 运营分配节点
    approval_flows = ApprovalFlow.where({"id" => approval_flow_ids})
    coordinate_groups = approval_flows.map(&:coordinate_groups).flatten
    return coordinate_groups
  end

  #当前订单 运营负责人和 所选同组运营人员
  def operator_and_share_opertor
    last_operations = self.operations.last
    share_ams = last_operations ? last_operations.share_ams.pluck(:user_id) : []
    operator = self.operator_id ? self.operator_id : ''
    share_ams << operator
  end


  def share_order_user_ids
    self.share_orders.pluck(:share_id)
  end

  def share_order_user_ids= (user_ids)
    user_ids
  end

  def share_order_group_ids
    self.share_order_groups.pluck(:share_id)
  end

  def share_order_group_ids= (group_ids)
    group_ids
  end

  def share_order_user
    User.where(User.user_conditions(share_order_user_ids)).eager_load(:agency).map { |user| user.name + " ("+(user.agency.name rescue '')+")" }.join(',')
  end

  def examination_create(node_id, user, language)
    Examination.examination_create(node_id, user, self.id, 'Order', language)
  end

  #更新商机进度
  def set_business_opportunities_process(opportunity)
    business_opportunity_id = self.business_opportunity_orders.map(&:business_opportunity_id)
    if business_opportunity_id.present?
      process = case opportunity
                  when 'order_service_create' then
                    30
                  when 'order_approval' then
                    50
                  when 'contract_approval' then
                    100
                  else
                end
      business_opportunity = BusinessOpportunity.find business_opportunity_id.last
      current_process = business_opportunity.progress.nil_zero? ? 0 : business_opportunity.progress
      if process > current_process
        business_opportunity.progress = process
        business_opportunity.save
      end
    end
  end

  #当前用户对当前订单有哪些操作权限（订单修改、删除，产品修改，删除）
  def operate_authority(user, approval_node_ids, status)
    #普通运营被分配的订单，通过客户分享来的订单,毛利核算人员，合同审批人，财务/法务,运营分配人员  没有订单产品操作权限
    authority = []
    node_ids = approval_node_ids.class == Array ? approval_node_ids.uniq : approval_node_ids.split(',').uniq
    share_order_user = self.share_order_user_ids.include? user.id
    share_client_user = self.client.present? ? (self.client.share_client_user_ids.include? user.id) : false
    #订单创建者，订单销售人员，订单审批者（标准或者非标）,客户分享给当前销售的订单
    authority += %w[order_edit order_delete ad_edit ad_delete ad_create] if self.user_id == user.id || share_order_user || share_client_user
    if (node_ids.include? '2') || (node_ids.include? '3')
      is_standrd = self.is_standard
      current_order_approval_status = is_standrd == true ? status[2] : status[1]
      if current_order_approval_status == '1' && status[0] != '3' && status[3] != '3'
        authority += %w[order_edit]
      else
        authority += %w[order_edit order_delete ad_edit ad_delete ad_create]
      end
    end
    authority += %w[order_edit ad_edit] if node_ids.include? '1' #预审人员 只能编辑产品的配送点击量、调整预估ctr、订单的购买人群
    authority += %w[order_edit] if node_ids.include? '4' #法务财务 只能编辑合同编号
    return authority.uniq
  end

  #当前订单预估gp%
  def est_gp
    (self.budget.present? && !self.budget.nil_zero?) ? (self.advertisements.map(&:est_gp_value).inject(0) { |sum, i| sum+i.to_f } * 100 / self.budget).round(2) : 0.0
  end

  def order_attributes(params)
    date_range = params[:date_range].split('~')
    self.attributes = params[:order]
    self.free_tag = nil unless params[:order][:free_tag]
    self.start_date = date_range[0]
    self.ending_date = date_range[1]
    self.exclude_date = params[:exclude_dates].present? ? params[:exclude_dates].split(',') : []
    self.share_orders_attributes = to_hash_share(params[:share_order]) if params[:share_order].present?
    self.share_order_groups_attributes = to_hash_share(params[:share_order_group]) if params[:share_order_group].present?
    self.order_nonuniforms_attributes = Order.nonuniform_attributes(params) if self.whether_service == false

    business_opportunity_number = params[:order][:business_opportunity_number]
    whether_business_opportunity = params[:order][:whether_business_opportunity]
    if whether_business_opportunity == '1' && business_opportunity_number != ''
      self.business_opportunity_orders_attributes = [{:business_opportunity_id => business_opportunity_number}]
      #根据商机创建产品
      if params[:clone_id].blank?
        advertisements_attributes = Order.advertisements_from_business_opportunity(business_opportunity_number)
        self.advertisements_attributes = advertisements_attributes
      end
    end

    if params[:clone_id].present? #如果是复制订单克隆复制订单产品
      clone_order = Order.find_by :id => params[:clone_id]
      if clone_order
        advertisements_attributes = clone_order.clone_ad_attributes
        self.advertisements_attributes = advertisements_attributes
      end
    end

    return self
  end

  def business_opportunity_code
    (whether_business_opportunity && business_opportunity_number.present?) ? 'SO'+business_opportunity_number.to_s.rjust(9, '0') : '-'
  end

  #订单是否已分配策划人员
  def assign_planner
    self.business_opportunity_orders.map { |b| b.business_opportunity.cooperate_planner_id }.compact!
  end

  #订单历史操作记录
  def history_list_data
    examinations = self.examinations.where('node_id != 8').where.not("node_id = 3 and status = '1'")
    schedule_commit_user = self.schedule_commit_user
    schedule_commit_time = self.schedule_commit_time
    if schedule_commit_time.present?
      proof_submitter, proof_submit_time = schedule_commit_time, schedule_commit_time
      examination_proof = Examination.new
      examination_proof.node_id = 8
      examination_proof.status = '1'
      examination_proof.created_user = proof_submitter
      examination_proof.created_at = proof_submit_time
      examinations.push(examination_proof)
    end
    examinations.to_a.sort_by! { |examination| examination.created_at }
    return examinations
  end

  #更新订单下所有产品折扣
  def update_all_ads_discount
    self.advertisements.each { |ad| ad.update_discount }
  end

  #订单编辑验证方式
  def valid_edit(submit_to_edit)
    valid_by_type if submit_to_edit
  end

  #订单验证方式
  def valid_by_type
    whether_executive? ? self.valid_executive : self.invalid?
  end


  #排期表提交
  def proof_submit(current_user)
    self.proof_state = 0
    self.schedule_commit_user = current_user.name
    self.schedule_commit_time = Time.now
    self.save(:validate => false)
    approval_groups = self.approval_groups(4)
    language = I18n.locale.to_s
    contract_last_status = self.order_approval_node_state('contract')
    self.deal_proof_commit_mail(approval_groups, current_user, language) if contract_last_status == 1
  end

  #更新订单的code字段
  def update_order_code
    new_code = 'OR' + "%09d" % self.id
    self.update_columns({:code => new_code})
  end

  #提交审批订单属性验证
  def validate_order(position)
    valid_by_type
    if self.errors.any?
      html = ""
      submit_tip = position == 'show_page' ? I18n.t('order.form.order_commit_tip2') : I18n.t('order.form.order_commit_tip1', :title => self.title, :edit_order_url => "/#{I18n.locale}/orders/#{self.id}/edit?submit_to_edit=true")
      html << %Q(<div id="error_explanation" class="error sticker"><h2 style="font-size:20px;">#{submit_tip}</h2><ul>)
      self.errors.full_messages.each { |msg| html << %Q(<li>#{msg}</li>) }
      html << %Q(</ul></div>)
      return html
    end
  end

  #订单审批环节验证
  def validate_order_approval(current_user, node_id)
    if !self.is_gp_commit && self.is_jast_for_gp
      %Q(<div id="error_explanation" class="error sticker"> #{I18n.t("order.form.prechec_approval_tip", :gp_projection_url => "/#{I18n.locale}/orders/#{self.id}/edit?tab=tab-gp")}</div>)
    elsif node_id == '3'
      approval_gp_authority = ApprovalFlow.where({'id' => (self.current_flows(3) & current_user.special_approval_flows)}).order(:min, :max).first rescue []
      gp_range = Range.new(approval_gp_authority.min, approval_gp_authority.max) if !approval_gp_authority.blank?
      no_approval_permission if !current_user.administrator? && (approval_gp_authority.blank? || (gp_range && (!gp_range.include? self.net_gp)))
    end
  end

  #合同审批 验证排期表是否已经上传
  def validate_contract_approval
    %Q(<div id="error_explanation" class="error sticker"> #{I18n.t("order.form.contract_approval_tip")}</div>) if self.proof_state != '0'
  end

  #节点提交操作给审批人发邮件
  def send_email_to_approvers(current_user, node_id, examination_id, node_status, local_language)
    if node_id == 1 && self.assign_planner.present?
      PlannerWorker.perform(self.id, self.assign_planner, examination_id, node_status, local_language)
    else
      approval_groups = self.submit_node(node_id)
      OrderWorker.perform_async(self.id, approval_groups, examination_id, node_status, node_id, local_language) if approval_groups.present?
    end
    #预审提交时毛利预估未提交，发邮件给毛利预估人
    if node_id == 1 && self.is_jast_for_gp
      gp_node_status = self.order_approval_node_state('gp_control')
      self.send_email_to_gp_estimation(current_user, local_language) if gp_node_status == 0
    end
  end

  #审批人审批给销售发邮件
  def send_email_to_sales(current_user, node_id, status, examination_id, node_status, local_language)
    status_change, color_class_change, change_unstandard = order_approved(current_user, local_language, node_id) if (node_id == 2 || node_id == 3) && status == '2' #订单审批通过
    self.deal_reset_gp(current_user, local_language) if (node_id == 2 || node_id == 3) && status == '3' #订单审批不通过 重置GP状态
    self.contract_approved(examination_id, local_language) if node_id == 4 && status == '2' #合同审批通过 给运营分配审批者发邮件，更新商机进度为100%
    change_standard = self.gp_approved(current_user, local_language) if node_id == 7 && status == '2' #毛利核算审批通过
    other_useremail = User.where({"id" => self.operator_and_share_opertor}).map(&:useremail) if node_id == 5 # 运营分配后发邮件给运营邮件负责人和运营人员
    SaleWorker.perform_async(self.id, node_status, status, local_language, other_useremail, current_user.id) if status != '0'
    return status_change, color_class_change, change_unstandard, change_standard
  end

  #运营分配后处理运营分配数据
  def deal_operate_distribution(operator_id, option, operation_share_ams, comment)
    update_operator(operator_id)
    operation = Operation.create(:action => option, :comment => comment, :order_id => self.id)
    color_class = option == 'config_done' ? 'status-ready' : 'status-submit'
    if operation && operation_share_ams.present?
      user_ids = operation_share_ams.split(',')
      user_ids.each { |u| ShareAm.create(:user_id => u, :operation_id => operation.id) }
    end
    return color_class
  end

  def update_operator(operator_id)
    operator = (User.find operator_id).name rescue ''
    self.update_columns(:operator_id => operator_id, :operator => operator)
  end





  class << self

    def campaign_have_code(code)
      campaign_code = Order.find_by_sql(['select order_code from xmo.campaigns where order_code = ? ', code])
      return campaign_code.present? ? '1' : '0'
    end

    #根据商机自动生成订单
    def create_from_business_opportunity(business_opportunity_id)
      business_opportunity = BusinessOpportunity.find business_opportunity_id
      exist_service = business_opportunity.exist_service
      exist_msa = business_opportunity.exist_msa
      order = Order.new
      deliver_start_date = business_opportunity.deliver_start_date.to_date
      deliver_end_date = business_opportunity.deliver_end_date.to_date
      budget = business_opportunity.budget
      budget_currency = Currency.find(business_opportunity.currency_id).name
      client_id = business_opportunity.advertiser_id
      user_id = business_opportunity.owner_sale
      share_order_user = business_opportunity.cooperate_sales.split(',') rescue []
      last_update_user = User.find user_id
      client = Client.find client_id if client_id.present? rescue nil
      share_orders_attributes = (share_order_user+ [user_id]).map { |user| {:share_id => user.to_i} }
      order_title = business_opportunity.name
      errors_msg = ''
      if client.present?

        if exist_service
          #如果是service类创建服务类订单
          order.attributes = {:code => Order.create_sn,
                              :title => order_title,
                              :start_date => deliver_start_date,
                              :ending_date => deliver_end_date,
                              :budget => budget,
                              :budget_currency => budget_currency,
                              :client_id => client_id,
                              :user_id => user_id,
                              :whether_monitor => false,
                              :frequency_limit => false,
                              :client_material => false,
                              :planner_check => false,
                              :xmo_code => false,
                              :free_tag => "0",
                              :exclude_date => [],
                              :third_monitor_code => "AdMaster",
                              :linkman => client.present? ? client.clientcontact : "",
                              :whether_service => exist_service,
                              :whether_business_opportunity => true,
                              :business_opportunity_number => business_opportunity_id,
                              :share_orders_attributes => share_orders_attributes,
                              :business_opportunity_orders_attributes => [{:business_opportunity_id => business_opportunity.id}]
          }


        else
          #创建执行订单
          # share_orders_attributes = (share_order_user+ user_id).map{|user| {:share_id=> user}}
          advertisements_attributes = advertisements_from_business_opportunity(business_opportunity_id)

          channel_rebates = client.present? && client.client_channel.present? ? client.client_channel.channel_rebates : []
          order_rebate = 0.00
          channel_rebates.each { |channel_rebate|
            if deliver_start_date <= channel_rebate.end_date
              order_rebate = channel_rebate.rebate
              break;
            end
          }
          if advertisements_attributes.present?
            order.attributes = {:code => Order.create_sn,
                                :title => order_title,
                                :start_date => deliver_start_date,
                                :ending_date => deliver_end_date,
                                :budget => budget,
                                :budget_currency => budget_currency,
                                :client_id => client_id,
                                :user_id => user_id,
                                :whether_monitor => false,
                                :frequency_limit => false,
                                :client_material => false,
                                :planner_check => false,
                                :xmo_code => false,
                                :free_tag => '0',
                                :exclude_date => [],
                                :third_monitor_code => 'AdMaster',
                                :linkman => client.present? ? client.clientcontact : '',
                                :whether_msa => exist_msa,
                                :whether_service => exist_service,
                                :rebate => order_rebate,
                                :whether_business_opportunity => true,
                                :business_opportunity_number => business_opportunity_id,
                                :share_orders_attributes => share_orders_attributes,
                                :business_opportunity_orders_attributes => [{:business_opportunity_id => business_opportunity.id}],
                                :advertisements_attributes => advertisements_attributes
            }

          else
            errors_msg = 'no_product'
          end
        end
      else
        errors_msg = 'no_client'
      end
      unless errors_msg.present?
        if order.save!(:validate => false)
          order.update_columns({:last_update_user => last_update_user.present? ? last_update_user.name : ""})
          # order.set_business_opportunities_process("order_service_create")
        end
      end
      return order.id, errors_msg
    end

    def advertisements_from_business_opportunity(business_opportunity_id)
      business_opportunity = BusinessOpportunity.find business_opportunity_id
      business_opportunity_products = business_opportunity.business_opportunity_products
      budget_currency = Currency.find(business_opportunity.currency_id).name
      advertisements_attributes = []
      if business_opportunity_products.present?
        business_opportunity_products.each do |buniness_product|
          product = buniness_product.product
          if product.present?
            ad_type = product.product_category ? product.product_category.value : nil
            cost_type = product.sale_model
            public_price = product.public_price.present? ? product.public_price : 0
            discount = product.floor_discount.present? ? product.floor_discount * 100 : 0
            public_price = public_price * (ExchangeRate.get_rate(budget_currency, product.currency))
            cost = (discount * public_price).round(2)
            product_id = product.id
          end
          advertisement = {:budget_ratio => buniness_product.budget,
                           :ad_type => ad_type,
                           :cost_type => cost_type,
                           :cost => cost,
                           :price_presentation => '',
                           :nonstandard_kpi => '',
                           :discount => discount,
                           :product_id => product_id
          }
          advertisements_attributes << advertisement
        end
      end
      return advertisements_attributes
    end


    #可以预审的订单
    def orders_by_pre_check(order_id = nil)
      condition = " and t.id = #{order_id}" if order_id
      return Order.find_by_sql(" select distinct t.id from (select o.*,s.share_id from orders o left join  share_orders s on o.id = s.order_id ) t ,
                               permissions p where (t.user_id = p.create_user or t.share_id = p.create_user) and p.node_id =1 #{condition}")
    end

    #新增订单
    def new_order_by_user(params, user)
      order = user.orders.new(params[:order])
      return order.order_attributes(params)
    end

    #修改订单
    def update_order(params)
      order = Order.find(params[:id])
      origin_order = Order.new
      origin_order.attributes = order.attributes.deep_dup
      transaction do
        order.share_orders.destroy_all
        order.share_order_groups.destroy_all
        order.order_nonuniforms.destroy_all
        order.business_opportunity_orders.destroy_all
        return origin_order, order.order_attributes(params)
      end
    end

    def options_for_opportunity_id(user, order=nil, client_id =nil)
      user_opportunity_condition = ""
      user_client_id_condition = ""
      if !user.administrator?
        user_opportunity_condition = "  (bty.owner_sale = #{user.id} or find_in_set(#{user.id},bty.cooperate_sales)) and "
        user_client_id = Client.with_sale_clients(user, nil, 'all').select { |x| x.state == "approved" }.map(&:id)
        user_client_id = user_client_id.present? ? user_client_id.join(',') : "'no'"
        user_client_id_condition = " and bty.advertiser_id in (#{user_client_id})"
      end
      sql = "select distinct concat('SO',lpad(bty.id,9,'0')) opportunity_id,c.name currency_name, bty.*
           from business_opportunities bty left join business_opportunity_products bop on bty.id = bop.business_opportunity_id
           left join business_opportunity_orders bod on bty.id = bod.business_opportunity_id join xmo.currencies c on bty.currency_id = c.id where  #{user_opportunity_condition} 1=1 "

      if (order.present? && order.id.present? && order.client_id.present?)
        sql += " and bty.advertiser_id = #{order.client_id}"
      elsif client_id.present?
        sql += " and bty.advertiser_id = #{client_id}"
      else
        sql += user_client_id_condition
      end
      sql += " and  bty.deleted_at is null and bty.progress >0 and bop.deleted_at is null order by bty.id desc"
      business_opp = Order.find_by_sql("#{sql}") || []
    end

    #匀速投放数据封装
    def nonuniform_attributes(params)
      all_nonuniforms_date_range = params.select { |k, v| k =~ /^nonuniform_date_range(\d+|)$/ }.reject { |key, val| val == "" }
      all_nonuniform_budget = params.select { |k, v| k =~ /^nonuniform_budget(\d+|)$/ }.reject { |key, val| val == "" }
      order_nonuniform_attributes = []
      all_nonuniforms_date_range.each do |d|
        nonuniform_budget_val = all_nonuniform_budget[d[0].gsub("_date_range", "_budget")].present? ? all_nonuniform_budget[d[0].gsub("_date_range", "_budget")].gsub(',', '') : nil
        order_nonuniform_attributes << {:start_date => d[1].split("~")[0], :end_date => d[1].split("~")[1], :nonuniform_budget => nonuniform_budget_val}
      end
      return order_nonuniform_attributes
    end

    #克隆订单属性
    def clone_order(clone_order, current_user)
      order = Order.new
      order.attributes = clone_order.dup.attributes
      clone_client = clone_order.client
      if clone_client.present?
        order.title = clone_client.clientname + '_' + (100000..999999).to_a.sample.to_s
        if (!current_user.manageable_clients.include? clone_client) && (clone_client.user_id != current_user.id) && !current_user.administrator?
          order.client = nil
          order.linkman = nil
          order.linkman_tel = nil
        end
      end
      order.proof_state = nil
      order.code = Order.create_sn
      order.state = 'order_saved'
      order.share_order_user_ids = clone_order.share_order_user_ids
      order.share_order_user_ids = clone_order.share_order_group_ids
      return order
    end
  end


  private

  def ensure_attachment
    return unless new_record?
    self.schedule ||= Schedule.new
    self.proof ||= Proof.new
    self.executer ||= Executer.new
    self.draft ||= Draft.new
  end

  def generate_code
    return unless new_record?
    self.code = self.class.create_sn
  end

  def set_default_value
    return unless new_record?
    DEFAULTS.each do |k, v|
      self.send("#{k}=", v)
    end
  end

  def first_find(arr, f)
    j = 0
    arr.each_with_index do |a, i|
      if a == f
        j = i
        break
      end
    end
    return j
  end

  def last_find(arr)
    j = 0
    m = 0
    arr.reverse.each_with_index do |s, i|
      j = i
      m =s
      break if s > 0
    end
    return 5-j-1, m
  end

  #订单各标签状态封装
  def order_status(status, is_non_standart)
    new_status = (status.split(',').insert(3, self.proof_state == '0' ? '2' : '0').map { |statu| statu.to_i })
    new_status.delete_at(6)
    if is_non_standart
      new_status.delete_at(1)
    else
      new_status.delete_at(2)
    end
    return new_status
  end

  def validate_columns_present?(columns)
    column_present = false
    columns.each do |col|
      if !self.send(:col).present?
        column_present = true
        break
      end
    end
    return column_present
  end

  def to_hash_share(share_ids)
    share_ids.reduce([]) { |array, e| array << {:share_id => e} }
  end

  def color_class_by_status(status)
    color_class = case status
                    when '1' then
                      'status-submit'
                    when '2' then
                      'status-ready'
                    when '3'
                      'status-error'
                  end
  end

  #没有审批权限
  def no_approval_permission
    %Q(<div id="error_explanation" class="error sticker"> #{I18n.t('order.form.have_no_power')} </div>)
  end

end

require_dependency 'order/workflow'
require_dependency 'order/scopes'
