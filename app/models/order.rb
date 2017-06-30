#encoding: utf-8
class Order < Base
  include SerialNumber
  include Extract

  include Condition
  include SendOrderAdvertisementClient
  CURRENCY = ["RMB","HKD","USD","SGD","TWD","KRW","JPY","MYR","GBP","EUR","AUD","THB","RUB","IDR"].freeze

  serialize :city

  serialize :country

  serialize :delivery

  serialize :third_monitor

  serialize :exclude_date

  serialize :check_download_attr, Hash

  CALLBACK_EDIT_STATES =%w{rejected order_saved planner_approved planner_unapproved sales_manager_unapproved sales_president_unapproved proof_ready proof_unapproved legal_officer_unapproved examine_completed }
  
  REGIONAL = ["EMPTY","SPECIAL","OTHER","NATION", "US_UK_AU_NZ_MY", "HK_TW_MA_SG", "OTHER_COUNTRY","SPECIAL_CITY","SPECIAL_COUNTRY"]

  CHINA_REHIONAL = ["SPECIAL","OTHER","NATION","SPECIAL_CITY"]
  
  REPORTTEMPLATE = ["standard","client"]

  REPORTPERIOD = ["daliy","month","closure"]

  THIRDMONITOR = ["AdMaster","other"]
  
  COUNTRY_OPTIONS = [["中国", "CHINA"],["美国", "US"], ["英国", "UK"],["澳洲", "AU"],["新西兰", "NZ"],["马来西亚", "MY"],
                     ["香港", "HK"], ["台湾", "TW"], ["澳门", "MA"], ["新加坡", "SG"], ["其他","OTHER_COUNTRY"]]

  TRY_OPTIONS = [[I18n.t("order.form.china_option"), "china"], [I18n.t("order.form.us"), "US"], [I18n.t("order.form.uk"), "UK"], [I18n.t("order.form.au"), "AU"], [I18n.t("order.form.nz"), "NZ"], [I18n.t("order.form.my"), "MY"], [I18n.t("order.form.sg"), "SG"], [I18n.t("order.form.hk"), "HK"], [I18n.t("order.form.ma"), "MA"], [I18n.t("order.form.tw"), "TW"],
                 [I18n.t("order.form.germany"), "Germany"], [I18n.t("order.form.france"), "France"], [I18n.t("order.form.south_korea"), "South Korea"], [I18n.t("order.form.japan"), "Japan"], [I18n.t("order.form.philippines"), "Philippines"],[I18n.t("order.form.russia"), "Russia"], [I18n.t("order.form.india"), "India"], [I18n.t("order.form.vietnam"), "Vietnam"],
                 [I18n.t("order.form.laos"), "Laos"],[I18n.t("order.form.myanmar"), "Burma"], [I18n.t("order.form.thailand"), "Thailand"], [I18n.t("order.form.spain"), "Spain"], [I18n.t("order.form.portugal"), "Portugal"], [I18n.t("order.form.sweden"), "Sweden"], [I18n.t("order.form.cambodia"), "Kampuchea"],[I18n.t("order.form.pakistan"), "Pakistan"],
                 [I18n.t("order.form.canada"), "Canada"], [I18n.t("order.form.mexico"), "Mexico"], [I18n.t("order.form.austria"), "Austria"], [I18n.t("order.form.ireland"), "Ireland"], [I18n.t("order.form.netherlands"), "Holland"], [I18n.t("order.form.switzerland"), "Switzerland"], [I18n.t("order.form.belgium"), "Belgium"],
                 [I18n.t("order.form.luxembourg"), "Luxemburg"], [I18n.t("order.form.mongolia"), "Mongolia"], [I18n.t("order.form.north_korea"), "North Korea"], [I18n.t("order.form.indonesia"), "Indonesia"], [I18n.t("order.form.finland"), "Finland"], [I18n.t("order.form.ukraine"), "Ukraine"],[I18n.t("order.form.iran"), "Iran"],
                 [I18n.t("order.form.maldives"), "Maldives"], [I18n.t("order.form.brazil"), "Brazil"], [I18n.t("order.form.chile"), "Chile"], [I18n.t("order.form.argentina"), "Argentina"], [I18n.t("order.form.uruguay"), "Uruguay"], [I18n.t("order.form.paraguay"), "Paraguay"], [I18n.t("order.form.south_africa"), "South Africa"]]

  MAP_CITIES_ID = {"20163"=>"1003334","20184"=>"1003591","20164"=>"1003338","20171"=>"1003401","2344"=>"2344","2446"=>"2446","2158"=>"2158"}

  DEFAULTS = {
        :budget_currency => CURRENCY[0],
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
  has_many :order_attribute_values,inverse_of: :order
  has_many :business_opportunity_orders,inverse_of: :order

  has_many :gps, inverse_of: :order

  has_many :share_orders
  accepts_nested_attributes_for :advertisements,:business_opportunity_orders,:share_orders, allow_destroy: true

  has_many :share_order_groups

  belongs_to :client , inverse_of: :orders

  belongs_to :client, inverse_of: :orders

  belongs_to :channel

  belongs_to :user, inverse_of: :orders

  belongs_to :industry, inverse_of: :orders

  has_many :examinations, inverse_of: :order, as: :examinable
  has_many :order_nonuniforms,inverse_of: :order
  has_many :operations, inverse_of: :order
  validates :code, presence: true, uniqueness: true
  # validates :ad_platform,presence: true, inclusion: { in: ADCOMBO.keys,message: "%{value} is not a valid type" }
  # validates :ad_type,presence: true, inclusion: { in: ADCOMBO.values.flatten,message: "%{value} is not a valid type" }
  validates :regional,presence: true, inclusion: { in: REGIONAL-[REGIONAL[0]] },if: :whether_executive?
  validates :budget_currency, inclusion: { in: CURRENCY,message: "%{value} is not a valid currency" }, presence: true
  # validates :cost_currency, inclusion: { in: CURRENCY,message: "%{value} is not a valid currency" }, presence: true
  # validates :cost_type, inclusion: { in: COSTTYPE,message: "%{value} is not a valid currency" }, presence: true
  validates :start_date, date:{on_or_before: :ending_date} ,presence: true
  validates :ending_date, presence: true
  validates :budget, presence: true,if: :whether_executive?
  # validates :cost, numericality: {greater_than: 0,less_than:1000}, presence: true 
  validates :extra_website,presence:true , if: :media_buying?
  # validates :linkman, presence: true
  validates :title, presence: true
  validates :title,uniqueness:true, if: :title_is_null?
  # validates :linkman_tel, presence: true
  # validates :budget, numericality: {greater_than: 0,less_than:10000000}, presence: true
  # validates :extra_website,presence:true , if: :media_buying?
  validates :interest_crowd,presence:true , if: :andience_buying?
  validate :valid_budget,if: :whether_service?
  validate :valid_delivery_date,if: :whether_nonuniform?
  validate :valid_delivery_budget, if: :whether_nonuniform?
  validates :msa_contract, presence: true, if: :validate_msa?
  validates :business_opportunity_number, presence: true, if: :whether_business_opportunity?

  attr_accessor :advertisement_tatol_budget_radio
  
  acts_as_list scope: :user

  after_initialize :ensure_attachment

  after_initialize :generate_code

  after_initialize :set_default_value
  before_save :update_order_regional, :update_last_user

  after_create :update_order_code
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
    errors.add(:nonuniform_date_range,I18n.t("order.nonuniform_date_range")) if self.order_nonuniforms.blank?
  end

  #订单名称是否为空
  def title_is_null?
    !self.title.blank?
  end
  def valid_delivery_budget
    errors.add(:nonuniform_budget,I18n.t("order.nonuniform_budget")) if self.order_nonuniforms.blank?
  end

  #服务订单预算，服务费，服务费率必填一项验证
  def valid_budget
    errors.add(:budget_service_charges_scale,I18n.t("order.budget_service_charges_scale")) if self.budget.blank? && self.service_charges.blank? && self.service_charges_scale.blank?
  end
  #删除订单gp未提交记录
  def delete_order_gps
    Gp.connection.delete "delete from gps where order_id = #{self.id}"
  end

  #获取订单通栏产品
  def map_cpc_advertisements
     self.advertisements.select{|ad|  ad.dsp_gp_ad_type? && !ad.any_not_advertisement_gp_finish? }
  end

  #获取订单通栏已分配完产品
  def over_map_cpc_advertisements
     self.advertisements.select{|ad|  ad.dsp_gp_ad_type? && ad.any_not_advertisement_gp_finish? }
  end

  #当前需要分配媒体的非DSP产品列表
  def map_gp_advertisements
     self.advertisements.select{|ad| ad.un_dsp_gp_ad_type? && !ad.any_not_advertisement_gp_finish? }
  end

  #已分配完媒体的非DSP产品列表
  def over_map_gp_advertisements
     self.advertisements.select{|ad| ad.un_dsp_gp_ad_type? && ad.any_not_advertisement_gp_finish? }
  end

  #是否所有非RTB订单媒体GP已分配完
  def any_not_order_gp_finish?
    map_advertisements = self.advertisements.select{|ad| ad.un_dsp_gp_ad_type? }
    finish_order_gp_map = true
      map_advertisements.each do |advertisement|
       finish_order_gp_map = false if !advertisement.any_not_advertisement_gp_finish?
      end
    return finish_order_gp_map
  end

  #是否所有需计算GP的订单媒体GP已分配完
  def all_order_gp_finish?
    map_advertisements = need_ask_for_gp_rake
    finish_order_gp_map = true
      map_advertisements.each do |advertisement|
       finish_order_gp_map = false if !advertisement.any_not_advertisement_gp_finish?
      end
    return finish_order_gp_map
  end

  #订单整体GP
  def get_order_gp
    order_gp = 0.00
    (over_map_gp_advertisements+over_map_cpc_advertisements).each do |advertisement|
      order_gp += advertisement.get_advertisement_gps
    end
    return order_gp
  end

  #此订单需分量的话相关需要分量的产品
  def need_ask_for_gp_rake
    self.advertisements.select{|ad| ad.gp_ad_type? }
  end

  #本订单有产品不需要gp分量
  def any_need_have_gp_control?
     self.advertisements.any?{|adv| adv.un_gp_ad_type?}
  end

  #判断此订单是否需要分量
  def jast_for_gp_advertisement?
    # self.advertisements.present? && !self.any_need_have_gp_control? && china_regional? && self.need_ask_for_gp_rake.size >0 && !self.whether_service?
    !self.whether_service?
  end

  #此订单 预审 审批环节最后一次操作状态
  def precheck_approval_node_state(node_name)
   node_id =  is_standard ? "3" : "2"  if node_name == "order_approval"
   node_id = "1" if node_name == "pre_check"
   node_id = "4" if node_name == "contract"
   node_id = "7" if node_name == "gp_control"
   examination = Examination.where({"examinable_id"=>self.id,"examinable_type"=>"Order","node_id"=> node_id}).order("created_at").last
   examination.status if examination.present?
  end




  #订单整体GP%
  def get_order_gp_rake
    map_advertisements_budget = 0.00
    map_advertisements = need_ask_for_gp_rake
    map_advertisements.each do |map_advertisement|
      map_advertisements_budget += self.budget.to_f * (map_advertisement.budget_ratio.to_f / 100.00)
    end
    return (map_advertisements_budget == 0 ? 0 : get_order_gp / map_advertisements_budget)
  end

  #订单是否存在并小于40/100(判断发邮件给总裁审批)
  def send_email_to_approve?
     max = self.unstandard_range[1]
    self.gp_check == true && max != 0.0 && self.net_gp.to_f <= max
  end



  #自动分配RTB通栏类型产品gp
  def audo_finish_rtb_gp
      map_cpc_advertisements.each do |cpc_advertisement|
        if cpc_advertisement.have_admeasure_map?
          cpc_advertisement.admeasures.each do |admeasure|
            city = admeasure[0]
            if cpc_advertisement.meida_rtb_price(city).present?

            gp = Gp.new
            gp.city = city
            gp.media = "RTB"
            gp.media_id = 0 
            gp.media_type = "NA"
            gp.media_form = "DSP"
            gp.ad_original_size = "NA"
            gp.ad_expand_size = "NA"
            gp.ctr = "NA"
            gp.pv_config = (cpc_advertisement.total_cpm_show(city) / 1000.00).round(2)
            gp.pv_config_scale = 100
            gp.order_id = self.id  
            gp.advertisement_id = cpc_advertisement.id
            gp.average_cost_cpc = cpc_advertisement.get_average_cost(city)
            gp.save_flag = true
            gp.save
            gp.gp = gp.get_gp
            gp.save
              end
          end
        else
            gp = Gp.new
            gp.city = "-"
            gp.media = "RTB"
            gp.media_id = 0 
            gp.media_type = "NA"
            gp.media_form = "DSP"
            gp.ad_original_size = "NA"
            gp.ad_expand_size = "NA"
            gp.ctr = "NA"
            gp.pv_config = (cpc_advertisement.total_cpm_show("-") / 1000.00).round(2)
            gp.pv_config_scale = 100
            gp.order_id = self.id  
            gp.advertisement_id = cpc_advertisement.id
            gp.average_cost_cpc = cpc_advertisement.get_average_cost
            gp.save_flag = true
            gp.save
            gp.gp = gp.get_gp

            gp.save
        end
      end
  end

  def proceed_delete?
    !self.proof_attachment.url
  end
  
  def clone_ads
    new_ads = []
    for ad in self.advertisements
        new_ad_clone_attributes = ad.dup.attributes
        new_ad = Advertisement.new
        new_ad.attributes = new_ad_clone_attributes
        new_ads << new_ad
    end
    new_ads
  end

  def clone_nonuniforms
    new_nonumiforms = []
    for nonuniform in self.order_nonuniforms
      new_nonumiform_attributes = nonuniform.dup.attributes
      new_nonumiform = OrderNonuniform.new
      new_nonumiform.attributes = new_nonumiform_attributes
      new_nonumiforms << new_nonumiform
    end
    new_nonumiforms
  end

  def state_class
    self.state == 'rejected' ? 'red_mark' : (self.state == 'examine_completed' ? 'green' : '')
  end
  
  def tatol_budget_radio_is_100
    self.advertisements.present? && self.advertisements.map(&:budget_ratio_show).inject(0, :+).round(2) == self.budget.to_f
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

  def launch_type
    _ = []
    _ << 'MEDIA_BUYING' if media_buying? 
    _ << 'ANDIENCE_BUYING' if andience_buying?
    _.map{|buying| I18n.t buying }.join(',')
  end
  
  def report_period_show
    self.report_period.split(",") if self.report_period
  end

  def update_last_user_and_last_time(user)
    order_approval_status = precheck_approval_node_state("order_approval")
    contract_status = precheck_approval_node_state("contract")
    precheck_status = precheck_approval_node_state("pre_check")
    xmo_order_state = (self.xmo_order_state == 'examine_completed' || (order_approval_status == "2" && contract_status == "2" )) ?  "examine_completed" : ""
    state = (order_approval_status == "2" && contract_status == "2")  ?  "examine_completed" : ""
    self.update_columns(:last_update_user => user, :last_update_time => Time.now,:state => state, :xmo_order_state=>xmo_order_state)
  end

  #gp列表是否显示
  def gp_form_show?(current_user)
    tag_gp = "hide"
    if ( self.over_map_gp_advertisements.size>0 && self.any_not_order_gp_finish? )
      tag_gp = ""
    elsif (self.advertisements.select{|ad|ad.ad_type == "BAN"}.size>0 && (self.map_gp_advertisements.size == 0) && map_cpc_advertisements.size == 0 )
      tag_gp = ""
    elsif ( self.map_gp_advertisements.size>0 && !self.any_not_order_gp_finish? )
      tag_gp = ""
    end
    return tag_gp
  end


  #获取媒体投放地域方式
  def media_send_city
    media_send_city = ""
    if self.new_regions.present?
    regions = JSON.parse self.new_regions
    isAllChina = regions[0]["isChinaAll"] if regions[0].present?
    provinces =  regions[0].present? ? regions[0]["province"] : []
    map_province_id = MAP_CITIES_ID.invert
     if isAllChina
       media_send_city =  "全国通投"
     else
       all_province_city = true
       provinces.each do |province|
         province_id = map_province_id[province["province_id"]].present? ? map_province_id[province["province_id"]] : province["province_id"]
         city_id = province["city_id"]
         city_size = city_id.split(",")
         if province_city_num[province_id] != city_size
           all_province_city = false
           break
         end
       end

          if all_province_city
            media_send_city =  "按省投放"
          else
            media_send_city = order_city_name(true)
          end

     end

    end
    return media_send_city

  end


  #地域是否选择全部
  def china_region_all?
     china_all = false
     if self.new_regions.present?
       regions = JSON.parse self.new_regions
       china_all = regions[0]["isChinaAll"] if regions[0]["country"] == "china"
     end
    return china_all
  end



  #各省下城市个数
  def province_city_num
   locationCodes = LocationCode.find_by_sql("select province_id,count(*) as num from location_codes where country_name in ('China','Taiwan','Hong Kong','Macau')  group by province_id")
   province_city_count = locationCodes.map{|x| [x["province_id"],x["num"]]}.to_h
  end


  #城市匹配
  def map_city(language = nil)
    if self.id > 1537
    ad_region_name(language)
    else
      order_city_name
    end
  end



  def map_country(language = nil)
    language = language.present? ? language : I18n.locale.to_s
    country = []
    if self.new_regions.present?
    new_regions = JSON.parse self.new_regions
    new_regions.each{|region|
      if china_region_all?
        country << (language == "en" ? "All China" : "全中国" ) if region["country"] == "china"
      else
        country << (language == "en" ? "China" : "中国" ) if region["country"] == "china"
      end
      # binding.pry
      if region["country"] == "foregin"
      foregin_countries =  LocationRegion.where({"country_id"=> region["country_id"].split(",")}).map{|foregin_country| language == "en" ? foregin_country.continent_name_en : foregin_country.country_name}
      country += foregin_countries
      end
    }
    end
    country.join(" ").strip
  end

  def period
    (ending_date - start_date).to_i - exclude_date.size + 1
  end

  def industry_name
    industry.present? ?  (I18n.locale.to_s == "en" ? industry.name : industry.name_cn) : ''
  end

  def beginning?
     DateTime.now.to_i >= start_date.at_beginning_of_day.to_i
  end

  def during?
    current = DateTime.now.to_i
    current >= start_date.at_beginning_of_day.to_i and DateTime.now.to_i <= ending_date.at_end_of_day.to_i
  end

  def expire?
    DateTime.now.to_i > ending_date.at_end_of_day.to_i
  end

  def additional?
    whether_monitor && description.present?
  end

  def set_operator(user)
    user = User.find_by(self.class.user_conditions(user))
    return false if self.state != "examine_completed" || !%{operater operaters_manager}.include?(user.role_name)
    update_column(:operator,user.name)
  end

  def get_operator 
    return nil if self.operator.nil?
    User.find_by(self.class.user_conditions(self.operator))
  end

  def generate_schedule
    generator =  Generator::ExcelGenerator.new(self)
    generator.generate_schedule
  end

  def generate_executer
    generator =  Generator::ExecuterGenerator.new(self)
    generator.generate_executer
  end

  def nonstandard?
    advertisements.any?{|adv| adv.nonstandard?}
  end

  def underpraise?
    advertisements.any?{|adv| adv.underpraise?}
  end
  
  def planner_ctr?
    advertisements.any?{|adv| adv.diff_ctr?}
  end
  
  def have_state?(state)
    self.examinations.any?{|ex| ex.from_state == state}
  end

  #订单产品询价&询量审批团队是否包含当前用户
  def in_product_approval_team?(user_id)
    advertisements.any?{|adv| adv.in_product_approval_team?(user_id)}
  end

  #订单产品执行团队是否包含当前用户
  def in_product_executive_team?(user_id)
    advertisements.any?{|adv| adv.in_product_executive_team?(user_id)}
  end

  #当前用户是否可以修改编辑该订单
  def can_edit?(user,super_admin_ids=nil)
    user_id =  user.id
    share_orders = ShareOrder.where(" share_id = ? ",user_id).map(&:order_id)
    ( self.user_id == user_id ) || (share_orders.include? self.id) || user.administrator?
  end

  #判断订单审批过程中，订单是否可以编辑提示
  def self.order_cannot_edit(order_id)
    sql = "select id from examinations where examinable_type = 'Order' and status != 0 and examinable_id = ? limit 1"
    Order.find_by_sql([sql,order_id]).present?
  end

  def state_is?(states)
      states.include? self.state.to_s
  end

  def current_user_order?(current_user)
    self.user_id == current_user.id
  end

  def nonstandard_order?
    self.underpraise? || self.other_product? || self.unnstandard_country? || self.planner_ctr?
  end

  def other_product?
    advertisements.any?{|adv| adv.other_product?}
  end

  def before_other_ctr?
    advertisements.any?{|adv| adv.before_other_ctr? && adv.ad_type != "OTHERTYPE"}
  end

  def unnstandard_country?
    self.regional == "SPECIAL_COUNTRY"
  end

  def china_regional?
    ["SPECIAL","OTHER","NATION","SPECIAL_CITY"].include?(self.regional)
  end

  def callback_edit_states?
    state_is?(CALLBACK_EDIT_STATES)
  end


  def provinces
    self.delivery_type == "2" ? self.delivery_city_level : self.delivery_province
  end

  def admeasure_miss_100?
    advertisements.all?{|adv| adv.admeasure_miss_100?}
  end

  def return_gp_result(language =nil)
    min,max = self.unstandard_range
    gp_rake = self.net_gp.present? ? self.net_gp : 0.0
    gp_text = I18n.t("order.form.to_be_improved_immediately2",:locale => (language.present? ? language.to_sym : I18n.locale))
    if (gp_rake < min)
      gp_text = I18n.t("order.form.to_be_improved_immediately2",:locale => (language.present? ? language.to_sym : I18n.locale))
    elsif (min <= gp_rake && gp_rake <= max)
      gp_text = I18n.t("order.form.yet_to_improve_gp2",:locale => (language.present? ? language.to_sym : I18n.locale))

    elsif (max < gp_rake && gp_rake < 100)
      gp_text = I18n.t("order.form.gp_meet_standard2",:locale => (language.present? ? language.to_sym : I18n.locale))
    end
    return gp_text
  end
  #订单城市解析
  def order_city_name(translate = nil)
    language =  I18n.locale.to_s
    cityname = []
    if self.new_regions.present?
      new_regions = []
      regions = JSON.parse self.new_regions

      regions.each do |r|
        if r["province"]
          r["province"].each do |p|
            new_regions << p["city_id"].split(',') if p["city_id"].present?
          end
        end
      end
      new_regions.flatten
      city1 =  LocationCode.where({"criteria_id"=> new_regions}).where("city_name_cn is not null and city_name is not null").collect{|city| (translate || language == "zh-cn") ?  city.city_name_cn : city.city_name}
      city2 = ProvinceCode.where({"code_id"=> new_regions}).collect{|province| (translate || language == "zh-cn") ?  province.name_cn : province.name }
      cityname = (city1+city2).sort
    end
    return cityname.join(",")
  end

  #产品地域预算 地域解析（支持按省或地市预算）
  def ad_region_name(language = nil)
    language = language.present? ? language : I18n.locale.to_s
    cityname = []
    if self.new_regions.present?
      new_regions = []
      regions = JSON.parse self.new_regions
      regions.each do |r|
        if r["province"]
          r["province"].each do |p|
            province_id = p["province_id"]
            city_id = p["city_id"].split(",")
            if province_city_num[province_id] != city_id.size
              new_regions << city_id if city_id.present?
            else
              new_regions << province_id
            end
          end
        end
      end
      new_regions.flatten
      city1 =  LocationCode.where({"criteria_id"=> new_regions}).where("city_name_cn is not null and city_name is not null").collect{|city|  language == "zh-cn" ?  city.city_name_cn : city.city_name}
      city2 = ProvinceCode.where({"code_id"=> new_regions}).collect{|province|  language == "zh-cn" ?  province.name_cn : province.name }
      cityname = city2 + city1.sort
    end
    return cityname.join(",")
  end




  #必填字段验证
  def validate_ability_column?
    list =[]
    if whether_service?
      tag = ["client_id","linkman","title","code","budget_currency","start_date","ending_date"]
      tag.each do |item|
        list << self.send("#{item}").present?
        list.any?{|v| v == false} || (self.budget.blank? || self.service_charges.blank? || self.service_charges_scale.blank?)
      end
    else
    tag = ["client_id","linkman","title","code","regional","budget_currency","start_date","ending_date","budget"]

    others = self.tatol_budget_radio_is_100 && !self.before_other_ctr? && self.admeasure_miss_100?
    tag.each do |item|
      list << self.send("#{item}").present?
    end
    # self.free_tag.present? || list.any?{|v| v == false}  || self.advertisements.any?{|ad| ad.product_id.blank? || ad.ad_type.blank?} || !others || ShareOrder.find_by_order_id(self.id).present? || ShareOrderGroup.find_by_order_id(self.id).present?
     list.any?{|v| v == false}  || self.advertisements.any?{|ad| ad.product_id.blank? || ad.ad_type.blank? || ad.cost.blank? } || !others || !ShareOrder.find_by_order_id(self.id).present? || !ShareOrderGroup.find_by_order_id(self.id).present?
    end
  end


  #订单关键字段改变时触发
  def update_order_examinations_status(origin_order,current_user)
    key2 = origin_order.budget != self.budget
    key3 = (origin_order.free_tag.present? ? origin_order.free_tag : "0") != self.free_tag
    key4 = origin_order.start_date != self.start_date || origin_order.ending_date != self.ending_date || origin_order.exclude_date.to_a != self.exclude_date.to_a
    #  key5 = (origin_order.new_regions != self.new_regions) && self.id > 1350
    if origin_order.new_regions.present?
      origin_order_regions =  JSON.parse origin_order.new_regions
      origin_order_regions[0].delete("city_level") if origin_order_regions[0]["city_level"].present?
    end
    if self.new_regions.present?
      new_regions =  JSON.parse self.new_regions
      new_regions[0].delete("city_level") if new_regions[0]["city_level"].present?
    end

    origin_order_foreign = []
    new_regions_foreign = []

    if new_regions.present? && origin_order_regions.present?
      if new_regions[0]["country"] == "china" && origin_order_regions[0]["country"] == new_regions[0]["country"]
        origin_order_province = []
        new_regions_province = []
        #china
        origin_order_province = origin_order_regions[0]["province"] if origin_order_regions[0]["province"].present?
        new_regions_province = new_regions[0]["province"] if new_regions[0]["province"].present?
        origin_order_province = origin_order_province.sort{|x,y| y["province_id"] <=> x["province_id"]}
        new_regions_province = new_regions[0]["province"].sort{|x,y| y["province_id"] <=> x["province_id"]} if new_regions[0]["province"].present?

        #foreign
        origin_order_foreign = origin_order_regions[1]["country_id"].split(",").sort{|x,y| x <=> y} if origin_order_regions[1].present?
        new_regions_foreign = new_regions[1]["country_id"].split(",").sort{|x,y| x <=> y} if new_regions[1].present?
        key5 = (origin_order_province != new_regions_province) || (origin_order_foreign != new_regions_foreign)
      elsif new_regions[0]["country"] == "foregin" && origin_order_regions[0]["country"] == new_regions[0]["country"]
        origin_order_foreign = origin_order_regions[0]["country_id"].split(",").sort{|x,y| x <=> y}
        new_regions_foreign = new_regions[0]["country_id"].split(",").sort{|x,y| x <=> y}
        key5 = origin_order_foreign != new_regions_foreign
      end
    elsif (new_regions.nil? && origin_order_regions.present?) || (origin_order_regions.nil? && new_regions.present?)
      key5 = true
    else
      key5 = false
    end

    p 88888888
    p key5

    key6 = (origin_order.whether_service?) != (self.whether_service?)
    key7 = origin_order.whether_nonuniform != self.whether_nonuniform

    if origin_order.budget_currency != self.budget_currency
      update_all_ads_discount
    end

    if (key2 || key3 || key4 || key5 || key6 || key7)
      self.change_examinations_status(current_user,'Order')
      self.update_columns({:gp_evaluate=>nil,:gp_check=>false,:net_gp=>nil})
      self.update_order_columns
    end
  end





  #根据选择的地域，更新订单中regional
  def update_order_regional
      select_regions = self.new_regions.present? ? JSON.parse(self.new_regions) : []
      if select_regions.present?
        if select_regions[0]["country"] == "china" && !select_regions[1].present?
          select_province = select_regions[0]["province"].present? ? select_regions[0]["province"].map{|p| p["province_id"]} : []
          select_city = select_regions[0]["province"].present? ? select_regions[0]["province"].map{|p| p["city_id"]}.join(",").split(",") : []
          first_city_level = select_province.all?{|p_id| ['1003401' ,'1003334','1003338','20181'].include?(p_id)} && select_city.all?{|p_id| ['1003401' ,'1003334','1003338','1003571','1003559'].include?(p_id)}
          self.regional = ((select_regions[0]["city_level"].present? && select_regions[0]["city_level"] == "1") && first_city_level) ? 'SPECIAL' : 'OTHER'
        else
          self.regional = 'OTHER_COUNTRY'
        end
      else
        self.regional = 'EMPTY'
      end
  end

  def update_last_user
    self.last_update_user = (Order.update_user.nil? ? "" : Order.update_user.name) rescue self.examinations.last.created_user
    self.last_update_time = Time.now
  end



  #是否为非标订单
  def order_standard_or_unstandard?
       self.send_email_to_approve?
  end

  #手动触发订单完整性验证
  def valid_executive
    self.valid?
    if self.advertisements.present?
      self.errors.add(:advertisement_ad_type, I18n.t("order.form.advertisement_tip3")) if self.advertisements.any?{|ad| ad.product_id.blank? || ad.ad_type.blank?}
      self.errors.add(:advertisement_tatol_budget_radio, I18n.t("order.form.budget_tip2")) unless self.tatol_budget_radio_is_100
      self.errors.add(:advertisement_before_other_ctr, I18n.t("order.form.ctr_tip")) if self.before_other_ctr?
      self.errors.add(:advertisement_admeasure_miss, I18n.t("order.form.budget_tip1")) unless self.admeasure_miss_100?
      self.errors.add(:advertisement_cost, I18n.t("order.form.advertisement_tip4")) if self.advertisements.any?{|ad| ad.cost.blank?}
    else
      self.errors.add(:advertisement_num, I18n.t("order.form.advertisement_num"))
    end
    self.errors.add(:share_order_blank, I18n.t("order.form.order_owner_error")) unless ShareOrder.find_by_order_id(self.id).present?
    self.errors.add(:share_order_group_blank, I18n.t("order.form.order_group_error")) unless ShareOrderGroup.find_by_order_id(self.id).present?
  end

  #当所有标签都做提交操作时取 当前订单最小最左状态
  #当有标签做审批操作时取当前订单最右状态

  def map_order_status(status,is_non_standart,gp_submit_orders)

    order_status = order_status(status,is_non_standart)
    map_order_flows = [{1 =>[I18n.t("order.status.pre_sale_check"),I18n.t("order.status.pre_sale_check_gp"),I18n.t("order.status.pre_sale_check_gp_finish")],2 =>[I18n.t("order.status.pre_sale_checked"),I18n.t("order.status.pre_sale_finish_gp"),I18n.t("order.status.pre_sale_check_gp_checked")],3 =>I18n.t("order.status.pre_sale_unchecked")},
                       {1 =>[I18n.t("order.status.approving01"),I18n.t("order.status.approving02")],2 =>I18n.t("order.status.approved"),3 =>I18n.t("order.status.unapproved")},
                       {2 =>I18n.t("order.flow.schedule_list_submit")},
                       {1 =>I18n.t("order.status.contract_approving"),2 =>I18n.t("order.status.contract_approved"),3 =>I18n.t("order.status.contract_unapproved")},
                       {1 =>I18n.t("order.status.am_wait_distribute"),2 =>I18n.t("order.status.am_distributed")}]
    max = order_status.sort.last

    in_process = order_status.include? 1
    if max != 0
      if in_process
        #有环节为提交状态 取最左一个待审批状态
        if is_non_standart && (first_find(order_status,1) == 1) #非标订单
          map_order_flows[1][1][1]
        elsif !is_non_standart && (first_find(order_status,1) == 1) #标准订单
          map_order_flows[1][1][0]
        elsif  first_find(order_status,1) == 0
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
          map_order_flows[first_find(order_status,1)][1]
        end

      else  #全部做过审批操作 取最右
        n,m = last_find(order_status)
        if is_non_standart && (n == 1) && (m == 1) #非标订单
          map_order_flows[1][1][1]
        elsif !is_non_standart && (n == 1) && (m == 1) #标准订单
          map_order_flows[1][1][0]
        elsif  (n == 0) && (m == 2)
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

  #订单各标签状态封装
  def order_status(status,is_non_standart)
    status = status.split(",")
    status.insert(3,self.proof_state == "0" ? "2" : "0")
    new_status = status.map{|s| s.to_i}
    new_status.delete_at(6)
    if is_non_standart
      new_status.delete_at(1)
    else
      new_status.delete_at(2)
    end
    return new_status
  end

  # 当前订单GP管控状态
  def gp_controller_status
    if self.is_jast_for_gp && !self.whether_service?
      if self.is_gp_commit
        I18n.t("order.flow.gp_control_submit")
      else
       I18n.t("order.flow.gp_control_unsubmit")
      end
    else
       I18n.t("order.flow.unsupport_gp")
    end

  end

  def schedule_status
    # if ["0","2","3"].include? proof_state
    if proof_state == "0"
      I18n.t("order.flow.schedule_list_submit")
    else
      I18n.t("order.flow.schedule_list_unsubmit")
    end
  end
  # # 当前订单GP管控提交信息
  def gp_controller_node_message
    # current_status = gp_controller_status
    create_user = gp_commit_user.present? && self.is_gp_commit ? gp_commit_user : "-"
    create_time = gp_commit_time.present? && is_gp_commit ? gp_commit_time.localtime.strftime("%Y/%m/%d %H:%M") : "-"
    # create_group = create_user == "-" ? "" : Group.with_user(create_user).map(&:group_name).join(",")
    return create_user,create_time
  end

  # 当前订单排期表操作信息
  def schedule_node_message
    # current_status = schedule_status
    create_user = schedule_commit_user.present? && proof_state == "0" ? schedule_commit_user : "-"
    create_time = schedule_commit_time.present? && proof_state == "0" ? schedule_commit_time.localtime.strftime("%Y/%m/%d %H:%M") : "-"
    # create_group = create_user == "-" ? "" : Group.with_user(create_user).map(&:group_name).join(",")
    return create_user,create_time
  end

  #当前订单是否有地域分配
  def order_have_admeasure_map?
    advertisements.any? {|ad| ad.have_admeasure_map? }
  end


  #地域翻译
  def self.map_region_names(translate = nil,name)
    p 998888888888
    p name
    if name != "-" && name.present?
    city = name.split("市")[0]
    cities = LocationCode.find_by_sql("select city_name_cn,city_name from xmo.location_codes where country_name = 'China' and (city_name_cn = '#{city}' or city_name = '#{city}') union all select name_cn as city_name_cn,name as city_name from xmo.province_codes where   (name_cn = '#{city}' or name = '#{city}')").last
    city_name = (translate || I18n.locale.to_s == "zh-cn") ?  cities["city_name_cn"] : cities["city_name"]  if cities.present?
    else
    city_name = "-"
    end
  end

  #解析当前订单地域数据
  def get_new_regions
    new_regions = []
    regions = JSON.parse self.new_regions
    regions.each do |r|
      if r["country_id"]
        new_regions << r["country_id"].split(',')
      end
      if r["province"]
        r["province"].each do |p|
          if p["city_id"].blank?
            new_regions << MAP_CITIES_ID[p["province_id"]]
          else
            new_regions << p["city_id"].split(',')
          end
        end
      end
    end
    new_regions.flatten
  end

  #获取当前用户当前订单所在运营审批流
  def order_operation_flow_users
    User.with_groups_name(operation_am_group).uniq
  end


  #当前订单运营分配人员和共享人员
  # def order_operator_and_share_ams
  #    operator =  User.where(User.user_conditions(self.operator))
  #    ams = []
  #    if  operator.present?
  #      ams << operator.first.id
  #      ams << self.operations.last.share_ams.map(&:user_id).flatten if self.operations.last
  #    end
  #   return ams
  # end

  #处理订单邮件回复审批
  def deal_order_mail_approval(approval,node_id,language)
    nodes = [{1 =>["Pre-sales Approval","预审"]},{2 =>["Order Approval","审批"]},{3 =>["Non-standard Order Approval","特批"]},{4 =>["Contract Confirmation","合同确认"]},{5 =>["Operation Assignment","运营分配"]} ]
    node_status = nodes[node_id-1][node_id] if node_id != 7
    if approval
     status = 2
     approval = 1
    else
      status = 3
      approval = 0
    end

    examination = Examination.new    :node_id => node_id,
                                     :created_user => self.approver.nil? ? "" : self.approver.name,
                                     :status => status,
                                     :approval => approval,
                                     :examinable_id => self.id,
                                     :examinable_type => "Order",
                                     :language => language

    if ["2","3"].include? self.current_node_last_status(node_id)
      raise ActiveRecord::RecordNotFound
    elsif node_id == 7
     if status == 2
       #更新订单操作人信息
       self.update_gp_commit_info(self.approver)
       orderApprovalStatus = self.precheck_approval_node_state("order_approval")
       if orderApprovalStatus.to_i == 3  #重置订单审批节点状态
         self.reset_order_approval(self.approver)
       else #发邮件给大区经理
         self.deal_gp_commit_mail(language)
       end
       examination.save
     elsif status == 3
       raise ActiveRecord::RecordNotFound
     end
    else
      examination.save if node_id !=1
    #合同审批通过 给运营分配审批者发邮件
    if node_id == 4 && status == 2
      approval_groups = self.approval_groups(5)
      oprate_node_status = ["Job Assignment","运营分配"]
      OrderWorker.perform_async(self.id,approval_groups,examination.id,oprate_node_status,5,language) if approval_groups.present?
      self.set_business_opportunities_process("contract_approval")
    end

    #订单审批通过 更新商机进度为50%
    if (node_id == 2 || node_id == 3) && status == 2
      self.set_business_opportunities_process("order_approval")
      if node_id == 2  #大区经理审批
        if self.net_gp.blank?
          self.save_gp_check(self.approver)
        end
        if order_standard_or_unstandard?
          self.deal_region_manager_approval(language)
        end
      end
    end

    #订单审批不通过 重置GP状态
    if (node_id == 2 || node_id == 3) && status == 3
      self.deal_reset_gp(self.approver,language)
    end

    SaleWorker.perform_async(self.id,node_status,status,language,nil,self.approver.id)
    end
  end

  #GP审批通过后发邮件给大区经理
  def deal_gp_commit_mail(language)
   if self.precheck_approval_node_state("order_approval") == "1"
    node_status =  ["Order Approval","审批"]
    examinations = Examination.where({"examinable_id"=>self.id,"examinable_type"=>"Order","node_id"=> 2}).order("created_at")
    if examinations.present?
      examination_id =  examinations.last.id
      approval_groups = self.approval_groups(2)
      OrderWorker.perform_async(self.id,approval_groups,examination_id,node_status,2,language)
    end
   end
  end

  #更新gp操作人信息
  def update_gp_commit_info(current_user)
    username = current_user.nil? ? '' : current_user.name
    self.update_columns(:gp_commit_user => username,:gp_commit_time => Time.now,:last_update_user => username,:last_update_time => Time.now,:is_gp_commit => true)

  end

  #GP审核通过后，如果订单审批未通过则重置订单审批节点状态

  def reset_order_approval(current_user)
      change_standard_approval = self.change_examination_some_node_status(2,current_user)
      change_unstandard_approval = self.change_examination_some_node_status(3,current_user)
     if change_standard_approval || change_unstandard_approval
      #更新订单为标准订单
       self.update_columns({:is_standard => false}) if self.is_standard
       self.update_columns({:gp_check =>false})
      end
  end



  #排期表提交后邮件发送
  def deal_proof_commit_mail(approval_groups,current_user,language)
    # 保存提交审批记录
    examination = Examination.create :node_id => 8,
                                     :created_user => current_user.name,
                                     :approval => '1',
                                     :examinable_id => self.id,
                                     :examinable_type => "Order",
                                     :status => '1',
                                     :language => language
    node_status = ["Contract Confirmation","合同确认"]
    examination_conaract = Examination.where({"examinable_id"=>self.id,"examinable_type"=>"Order","node_id"=> 4}).order("created_at").last

    OrderWorker.perform_async(self.id,approval_groups,examination_conaract.id,node_status,4,language)
  end

  #大区经理审批通过后,若非标则给特批人发邮件
  def deal_region_manager_approval(local_language)
       update_is_standard = self.update_is_standard
       special_approval_groups = self.approval_groups(3) #特批人
       examination_special_approval = Examination.create :node_id => 3,
                                                         :created_user => self.approver.nil? ? "" : self.approver.name,
                                                         :status => 1,
                                                         :approval => '1',
                                                         :examinable_id => self.id,
                                                         :examinable_type => 'Order',
                                                         :language => local_language
       color_class = "status-submit"
       change_unstandard = true if update_is_standard
       status = "1"
       #给特批人发邮件
       node_status = ["Non-standard Order Approval","特批"]
       OrderWorker.perform_async(self.id,special_approval_groups,examination_special_approval.id,node_status,3,local_language) if special_approval_groups.present?
       return status,color_class,change_unstandard
  end

  #更新订单为非标订单
  def update_is_standard
    self.update_columns(:is_standard =>true)
  end


  #预审提交发邮件给毛利预估人
  def send_email_to_gp_estimation(current_user,local_language)
    examination = Examination.create :node_id => 7,
                                     :created_user => current_user.name,
                                     :approval => '1',
                                     :examinable_id => self.id,
                                     :examinable_type => "Order",
                                     :status => '1',
                                     :language => local_language
    gp_approval_groups = self.approval_groups([7]) #（毛利预估人） 参数7表示 毛利预估节点
    gp_status = ["GP Estimation","毛利预估"]
    OrderWorker.perform_async(self.id,gp_approval_groups,examination.id,gp_status,7,local_language) if  gp_approval_groups.present?
  end


  #各节点提交，给审批人发邮件

  def submit_node(nodeid)
    approval_groups = self.approval_groups(nodeid)
    approval_groups = []  if nodeid == 2 &&  self.is_gp_commit == false && self.is_jast_for_gp #订单审批提交
    approval_groups = [] if nodeid == 4 && self.proof_state == "1" #合同确认提交
    return approval_groups
  end


  #订单审批不通过发邮件给毛利预估人

  def deal_reset_gp(current_user,local_language)
    reset_gp = self.change_examination_some_node_status(7,current_user)
    if reset_gp
    self.update_columns({:is_gp_commit => false,:gp_evaluate => nil,:net_gp => nil})
    gp_approval_groups = self.approval_groups([7]) #（毛利预估人） 参数7表示 毛利预估节点
    ResetGpWorker.perform_async(self.id,gp_approval_groups,local_language)
    end
  end


  #保存毛利预估，市推费用，净毛利
  def save_gp_check(current_user,gp_evaluate = nil,rebate = nil, market_cost = nil,net_gp =nil)
    gp_evaluate = gp_evaluate.present? ? gp_evaluate.to_f : self.est_gp
    rebate = rebate.present? ? rebate.to_f : (self.rebate.present? ? self.rebate : 0.0)
    market_cost = market_cost.present? ? market_cost.to_f : default_market_cost
    net_gp = net_gp.present? ? net_gp : (gp_evaluate - rebate - market_cost).round(2)
    self.update_columns(:gp_evaluate =>gp_evaluate ,:rebate=> rebate,:market_cost=>market_cost,:net_gp=>net_gp,:last_update_user => current_user.present? ? current_user.name : "",:last_update_time => Time.now,:gp_check=>true)
  end

  #根据销售bu使用不同市推默认值
  def default_market_cost
    user_ids =  self.share_order_user_ids << self.user_id
    bu = User.where({"id" => user_ids.uniq}).pluck(:bu).flatten.uniq rescue []
    default_market_cost = DefaultMarketCost.all.order(order_by: :asc)
    market_cost = 0.00
    if self.market_cost
      market_cost = self.market_cost.to_f
    else
      default_market_cost.each do |d|
        if bu.include? d.bu
          market_cost = d.market_cost
          break
        end
      end
    end

    return market_cost.to_f
  end

  #老数据地域迁移，迁移之前请先备份orders表。
  def self.migration_geo_data
    old_countries_key = {"US" =>"1840000000", "UK" => "1826000000", "AU" => "1036000000", "NZ" => "1554000000", "MY" => "1458000000", "SG" => "1702000000", "HK" => "2344" , "TW" => "2158", "MA"=> "2446"}
    old_name_key = {"BJ" => "1003334", "CQ" => "1003591", "SH" => "1003401", "TJ" => "1003338"}
    municipality_ids_key = {"20163" => "1003334","20184" => "1003591", "20171" => "1003401","20164" => "1003338"}
    old_municipality_ids = ["20163","20184","20171","20164"]
    new_municipality_ids = ["1003591","1003401","1003334","1003338"]
    municipality_name_key = ["BJ","CQ","SH","TJ"]
    first_tier_city = ["BJ", "TJ", "SH", "GZ31" ,"SZ14"]
    sql_find_all_provinces = "select province_id, GROUP_CONCAT(criteria_id) city_id from xmo.location_codes where province_id not in (1003591,1003401,1003334,1003338) and province_id is not null group by province_id "
    sql_find_all_cities_by_provinces = "select province_id, GROUP_CONCAT(criteria_id) city_id from cities where province_id in (?) and province_id is not null group by province_id"
    sql_find_cities_by_provinces = "select province_id, GROUP_CONCAT(criteria_id) city_id from cities where province_id in (?) and name_key in (?) and province_id is not null group by province_id"
    sql_find_all_cities_by_citylevel = "select province_id, GROUP_CONCAT(criteria_id) city_id from cities where province_id not in (1003591,1003401,1003334,1003338) and city_level in (1,2,3,4) and province_id is not null group by province_id"
    sql_find_cities_by_citylevel = "select province_id, GROUP_CONCAT(criteria_id) city_id from cities where province_id not in (1003591,1003401,1003334,1003338) and city_level in (?) and province_id is not null group by province_id"
    sql_find_by_name_key = "select province_id, GROUP_CONCAT(criteria_id) city_id from cities where province_id not in (1003591,1003401,1003334,1003338) and city_level in (?) and name_key in (?) and province_id is not null group by province_id"
    sql_find_all_cities_exclude_hk = "select province_id, GROUP_CONCAT(criteria_id) city_id from xmo.location_codes where province_id not in (1003591,1003401,1003334,1003338,2344,2446,2158) and province_id is not null group by province_id "
    sql_find_cities_exclude_hk = "select province_id, GROUP_CONCAT(criteria_id) city_id from cities where province_id not in (1003591,1003401,1003334,1003338,2344,2446,2158) and name_key in (?) and province_id is not null group by province_id "
    sql_find_countries_by_key = "select country_id from xmo.location_regions where continent_name_en in (?) and continent_name = '全球'"
    #orders = Order.where("id in (?)",[1163,1164,1165,1167,1168,1169,1170,1171,1172,1173,1174,1175,1176,1187,1188,1189])
    orders = Order.all
    orders.each do |order|
      provinces = []
      new_regions = []
      db_country = order.country.present? ? order.country : ["china"]
      name_en_array = db_country - ["all_countrys"]
      special_countries = db_country - ["special_country"]
      if !order.new_regions.present?
      case order.regional
        when "US_UK_AU_NZ_MY"
          country_ids = get_country_province_id(name_en_array, old_countries_key)
          new_regions = [{"country" => "foregin", "country_id" => country_ids.join(",")}]
        when "HK_TW_MA_SG"
          china_pro = name_en_array - ["SG"]
          provinces_ids = get_country_province_id(china_pro, old_countries_key)
          provinces = map_proid(provinces_ids)
          if !name_en_array.include?("SG")
            new_regions = [{"country" => "china", "province" => provinces, "isChinaAll" => false}]
          else
            new_regions = china_pro.length < 1 ? [{"country" => "foregin", "country_id" => "1702000000"}] : [{"country" => "china", "province" => provinces, "isChinaAll" => false}, {"country" => "foregin", "country_id" => "1702000000"}]
          end
        when "OTHER_COUNTRY"
          new_regions = nil
        when "SPECIAL_COUNTRY"
          if special_countries.join(",") == "all_countrys"
            #new_regions = order.new_regions
            provinces = find_all_china_regions(new_municipality_ids,sql_find_all_provinces)
            new_regions = [{"country" => "china", "province" => provinces.flatten, "city_level" => "1,2,3,4", "isChinaAll" => true}]
            country_ids = get_country_province_id(["US","UK","AU","NZ","MY","SG"], old_countries_key)
            foreign_countries = TRY_OPTIONS.map{|value| value[1]} - ["US","UK","AU","NZ","MY","SG","HK","TW","MA"]
            part_country_ids =  Order.find_by_sql([sql_find_countries_by_key,foreign_countries])
            country_ids = country_ids + part_country_ids.map(&:country_id)
            new_regions << {"country" => "foregin", "country_id" => country_ids.join(",")}
          else
            if special_countries.include?("china") || special_countries.include?("CHINA")
              provinces = find_all_china_regions(new_municipality_ids,sql_find_all_provinces)
              new_regions = [{"country" => "china", "province" => provinces.flatten, "city_level" => "1,2,3,4", "isChinaAll" => true}]
            elsif (special_countries - ["china","CHINA"]).length > 0
              hk_tw_ma = special_countries & ["HK","TW","MA"]
              exclude_hk_tw_ma = special_countries - ["HK","TW","MA"]
              special_results = special_countries & ["US","UK","AU","NZ","MY","SG"]
              custom_results = special_countries - ["US","UK","AU","NZ","MY","SG","HK","TW","MA"]
              if hk_tw_ma.length  > 0 && exclude_hk_tw_ma.length < 0
                provinces_ids = get_country_province_id(hk_tw_ma, old_countries_key)
                provinces = map_proid(provinces_ids)
                new_regions << [{"country" => "china", "province" => provinces, "isChinaAll" => false}]
              elsif hk_tw_ma.length > 0 && exclude_hk_tw_ma.length > 0
                provinces_ids = get_country_province_id(hk_tw_ma, old_countries_key)
                provinces = map_proid(provinces_ids)
                if special_results.length > 0
                  country_ids = special_results.present? ? get_country_province_id(special_results, old_countries_key) : []
                end
                if custom_results.length > 0
                  part_country_ids = custom_results.present? ?  Order.find_by_sql([sql_find_countries_by_key,custom_results]) : []
                end
                part_country_ids = part_country_ids.present? ? part_country_ids.map(&:country_id) : []
                country_ids = (country_ids.present? ? country_ids : [])  + part_country_ids
                new_regions << {"country" => "china", "province" => provinces, "isChinaAll" => false}
                new_regions << {"country" => "foregin", "country_id" => country_ids.join(",")}
              end
            end
          end
        else
          old_cities = order.city.present? && order.city.reject(&:empty?)
          old_deliveries = order.delivery
          if old_deliveries.present?
            delivery_provinces = old_deliveries["delivery_province"].reject(&:empty?)
            delivery_city_level = old_deliveries["delivery_city_level"].reject(&:empty?)
            provinces = []

            if old_deliveries["delivery_type"] == "1"
              if delivery_provinces.join(",") == "all_provinces" || !delivery_provinces.present?
                provinces = find_all_china_regions(new_municipality_ids,sql_find_all_provinces)
                new_regions = [{"country" => "china", "province" => provinces.flatten, "city_level" => "1,2,3,4", "isChinaAll" => true}]
              else
                (included_old_municipality_ids,exclude_old_municipality_ids) = get_municipality_arr(delivery_provinces,old_municipality_ids)
                if old_cities.present? && old_cities.join(",") == "all_cities"
                  if included_old_municipality_ids.present?
                    get_new_municipality_ids = get_country_province_id(included_old_municipality_ids, municipality_ids_key)
                    provinces << map_proid(get_new_municipality_ids)
                  end
                  #provinces = find_all_china_regions(get_new_municipality_ids,sql_find_all_cities_by_provinces,exclude_old_municipality_ids)
                  pro_ids = Order.find_by_sql([sql_find_all_cities_by_provinces, exclude_old_municipality_ids]) if exclude_old_municipality_ids.present?
                  provinces << map_proid_cityid(pro_ids)
                elsif !old_cities.present?
                  pro_ids = Order.find_by_sql([sql_find_all_cities_by_provinces, exclude_old_municipality_ids]) if exclude_old_municipality_ids.present?
                  provinces << map_proid_cityid(pro_ids)
                else
                  (include_municipality_name_key,exclude_municipality_name_key) = get_municipality_arr(old_cities,municipality_name_key)
                  get_new_municipality_ids = get_country_province_id(include_municipality_name_key, old_name_key)
                  provinces << map_proid(get_new_municipality_ids)
                  pro_ids = Order.find_by_sql([sql_find_cities_by_provinces,exclude_old_municipality_ids,exclude_municipality_name_key])
                  provinces << map_proid_cityid(pro_ids)
                end
                new_regions = [{"country" => "china", "province" => provinces.flatten, "isChinaAll" => false}]
              end
            elsif old_deliveries["delivery_type"] == "2"
              if delivery_city_level.join(",") == "all_city_level"
                provinces = find_all_china_regions(new_municipality_ids,sql_find_all_cities_by_citylevel)
                new_regions = [{"country" => "china", "province" => provinces.flatten, "city_level" => "1,2,3,4", "isChinaAll" => false}]
              else
                if old_cities.present? && old_cities.join(",") == "all_cities"
                  if delivery_city_level.present?
                    provinces << map_proid(new_municipality_ids - ["1003591"]) if delivery_city_level.include?("1")
                    provinces << map_proid(["1003591"]) if delivery_city_level.include?("2")
                    pro_ids = Order.find_by_sql([sql_find_cities_by_citylevel,delivery_city_level])
                    provinces << map_proid_cityid(pro_ids)
                    new_regions = [{"country" => "china", "province" => provinces.flatten, "city_level" => delivery_city_level.join(","), "isChinaAll" => false}]
                  else
                    provinces = find_all_china_regions(new_municipality_ids,sql_find_all_provinces)
                    new_regions = [{"country" => "china", "province" => provinces.flatten, "city_level" => "1,2,3,4", "isChinaAll" => true}]
                  end
                elsif !old_cities.present? && delivery_city_level.present?
                  provinces << map_proid(new_municipality_ids - ["1003591"]) if delivery_city_level.include?("1")
                  provinces << map_proid(["1003591"]) if delivery_city_level.include?("2")
                  pro_ids = Order.find_by_sql([sql_find_cities_by_citylevel,delivery_city_level])
                  provinces << map_proid_cityid(pro_ids)
                  new_regions = [{"country" => "china", "province" => provinces.flatten, "city_level" => delivery_city_level.join(","), "isChinaAll" => false}]
                else
                  select_name_key = old_cities.present? ? old_cities : []
                  (include_municipality_name_key,exclude_municipality_name_key) = get_municipality_arr(old_cities,municipality_name_key)
                  get_new_municipality_ids = get_country_province_id(include_municipality_name_key, old_name_key)
                  provinces << map_proid(get_new_municipality_ids)
                  pro_ids = Order.find_by_sql([sql_find_by_name_key,delivery_city_level,exclude_municipality_name_key])
                  provinces << map_proid_cityid(pro_ids)
                  regions = {"country" => "china", "province" => provinces.flatten, "isChinaAll" => false}
                  regions = (select_name_key & first_tier_city).length == 5 ? regions.merge("city_level" => "1") : regions
                  new_regions = [regions]
                end
              end
            elsif old_deliveries["delivery_type"] == "3"
              if old_cities.present? && old_cities.join(",") == "all_cities"
                provinces = find_all_china_regions(new_municipality_ids,sql_find_all_cities_exclude_hk)
                new_regions = [{"country" => "china", "province" => provinces.flatten, "city_level" => "1,2,3,4", "isChinaAll" => true}]
              elsif !old_cities.present?
                provinces = find_all_china_regions(new_municipality_ids,sql_find_all_cities_exclude_hk)
                new_regions = [{"country" => "china", "province" => provinces.flatten, "city_level" => "1,2,3,4", "isChinaAll" => true}]
              else
                (include_municipality_name_key,exclude_municipality_name_key) = get_municipality_arr(old_cities,municipality_name_key)
                get_new_municipality_ids = get_country_province_id(include_municipality_name_key, old_name_key)
                provinces << map_proid(get_new_municipality_ids)
                pro_ids = Order.find_by_sql([sql_find_cities_exclude_hk,exclude_municipality_name_key]) if exclude_municipality_name_key.present?
                provinces << map_proid_cityid(pro_ids)
                new_regions = [{"country" => "china", "province" => provinces.flatten, "isChinaAll" => false}]
              end
            else
              provinces = find_all_china_regions(new_municipality_ids,sql_find_all_provinces)
              new_regions = [{"country" => "china", "province" => provinces.flatten, "city_level" => "1,2,3,4", "isChinaAll" => true}]
            end
          else
            if old_cities.present? && (old_cities.join(",") == "all_cities" || old_cities.join(",") == "otherall")
              provinces = find_all_china_regions(new_municipality_ids,sql_find_all_provinces)
              new_regions = [{"country" => "china", "province" => provinces.flatten, "city_level" => "1,2,3,4", "isChinaAll" => true}]
            elsif !old_cities.present?
              new_regions = nil
            else
              (include_municipality_name_key,exclude_municipality_name_key) = get_municipality_arr(old_cities,municipality_name_key)
              get_new_municipality_ids = get_country_province_id(include_municipality_name_key, old_name_key)
              provinces << map_proid(get_new_municipality_ids)
              pro_ids = Order.find_by_sql([sql_find_cities_exclude_hk,exclude_municipality_name_key]) if exclude_municipality_name_key.present?
              provinces << map_proid_cityid(pro_ids)
              new_regions = [{"country" => "china", "province" => provinces.flatten, "isChinaAll" => false}]
            end
          end
      end
      order.update_columns({:new_regions => new_regions.present? ? ActiveSupport::JSON.encode(new_regions) : nil })
      #p order.errors.messages
      end
    end
  end

  def self.get_country_province_id(name_en_array, key)
    return [] if !name_en_array.present?
    country_ids = name_en_array.inject([]) do |f,item|
      f << key[item]
    end
    return country_ids
  end

  def self.map_proid(arr)
    return [] if !arr.present?
    arr.map do |id|
      ["province_id" => id.to_s, "city_id" => id.to_s]
    end.flatten
  end

  def self.map_proid_cityid(arr)
    return [] if !arr.present?
    arr.map do |id|
      ["province_id" => id.province_id.to_s, "city_id" => id.city_id.to_s]
    end.flatten
  end

  def self.get_municipality_arr(data_arr = [],municipality_array = [])
    return [] if data_arr.blank? || municipality_array.blank?
    return data_arr & municipality_array, data_arr - municipality_array
  end

  def self.find_all_china_regions(arr_ids,sql,sql_params1 = nil,sql_params2 = nil)
    #sql =~ /\?/
    provinces = []
    provinces << map_proid(arr_ids)
    sql_arry = [sql]
    sql_arry << sql_params1 if sql_params1.present?
    sql_arry << sql_params2 if sql_params2.present?
    pro_ids = Order.find_by_sql(sql_arry)
    provinces << map_proid_cityid(pro_ids)
    return provinces
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
    rebate = all_rebate.present? && self.id.present? ? all_rebate.first.rebate : 0.00
  end


  #当前订单 运营负责人和 所选同组运营人员
  def operator_and_share_opertor
   share_ams = self.operations.last ? self.operations.last.share_ams.pluck(:user_id) : []
   operator =  self.operator_id ?  self.operator_id : ""

   return share_ams << operator
  end


  def self.campaign_have_code(code)
    campaign_code = Order.find_by_sql(["select order_code from xmo.campaigns where order_code = ? ",code])
    return campaign_code.present? ? "1" : "0"
  end

  def share_order_user_ids
    self.share_orders.pluck(:share_id)
  end

  def share_order_user
    User.where(User.user_conditions(share_order_user_ids)).eager_load(:agency).map{|x| x.name + " ("+(x.agency.name rescue '')+")"}.join(", ")
  end

  #更新商机进度
  def set_business_opportunities_process(opportunity)
    business_opportunity_id =  self.business_opportunity_orders.map(&:business_opportunity_id)
     if business_opportunity_id.present?
       process = case opportunity
         when "order_service_create" then 30
         when "order_approval"  then 50
         when "contract_approval" then 100
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

  def self.options_for_opportunity_id(user,order=nil,client_id =nil)
    user_opportunity_condition = ""
    user_client_id_condition = ""
    if !user.administrator?
      user_opportunity_condition = "  (bty.owner_sale = #{user.id} or find_in_set(#{user.id},bty.cooperate_sales)) and "
      user_client_id = Client.with_sale_clients(user,nil,'all').select{|x| x.state == "approved" }.map(&:id)
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

  #当前用户对当前订单有哪些操作权限（订单修改、删除，产品修改，删除）
  def operate_authority(user,approval_node_ids,status)
    authority = [] #普通运营被分配的订单，通过客户分享来的订单,毛利核算人员，合同审批人，财务/法务,运营分配人员  没有订单产品操作权限
    node_ids = approval_node_ids.class == Array ? approval_node_ids.uniq : approval_node_ids.split(",").uniq

    share_order_user = self.share_order_user_ids.include? user.id
    share_client_user = self.client.present? ?  (self.client.share_client_user_ids.include? user.id) : false
    #订单创建者，订单销售人员，订单审批者（标准或者非标）,客户分享给当前销售的订单
    if self.user_id == user.id  || share_order_user || share_client_user
    authority += ["order_edit","order_delete","ad_edit","ad_delete","ad_create"]
    end

    if (node_ids.include? "2") || (node_ids.include? "3")
      is_standrd = self.is_standard
      current_order_approval_status = is_standrd == true ? status[2] : status[1]
      if current_order_approval_status == "1" && status[0]!="3" &&  status[3]!="3"
        authority += ["order_edit"]
      else
        authority += ["order_edit","order_delete","ad_edit","ad_delete","ad_create"]
      end
    end

    #预审人员 只能编辑产品的配送点击量、调整预估ctr、订单的购买人群
    if node_ids.include? "1"
    authority += ["order_edit","ad_edit"]
    end

    #法务财务 只能编辑合同编号
    if node_ids.include? "4"
      authority += ["order_edit"]
    end

    return authority.uniq
  end


  #当前订单预估gp%
  def est_gp
    (self.budget.present? && !self.budget.nil_zero?) ? (self.advertisements.map(&:est_gp_value).inject( 0 ) {|sum, i| sum+i.to_f } * 100 / self.budget).round(2) : 0.0
  end




  #根据商机自动生成订单
  def self.create_from_business_opportunity(business_opportunity_id)
    business_opportunity = BusinessOpportunity.find business_opportunity_id
    exist_service = business_opportunity.exist_service
    exist_msa = business_opportunity.exist_msa
    order = Order.new
    deliver_start_date =  business_opportunity.deliver_start_date.to_date
    deliver_end_date = business_opportunity.deliver_end_date.to_date
    budget = business_opportunity.budget
    budget_currency =  Currency.find(business_opportunity.currency_id).name
    client_id = business_opportunity.advertiser_id
    user_id = business_opportunity.owner_sale
    share_order_user = business_opportunity.cooperate_sales.split(",") rescue []
    last_update_user = User.find user_id
    client = Client.find client_id if client_id.present? rescue nil
    share_orders_attributes = (share_order_user+ [user_id]).map{|user| {:share_id=> user.to_i}}
    order_title = business_opportunity.name
    errors_msg = ""
  if client.present?

    if exist_service
      #如果是service类创建服务类订单
      order.attributes = {:code =>Order.create_sn,
                          :title => order_title,
                          :start_date=>deliver_start_date,
                          :ending_date=>deliver_end_date,
                          :budget=>budget,
                          :budget_currency=>budget_currency,
                          :client_id=>client_id,
                          :user_id=>user_id,
                          :whether_monitor=>false,
                          :frequency_limit=>false,
                          :client_material=>false,
                          :planner_check=>false,
                          :xmo_code =>false,
                          :free_tag =>"0",
                          :exclude_date => [],
                          :third_monitor_code => "AdMaster",
                          :linkman => client.present? ? client.clientcontact : "",
                          :whether_service =>exist_service,
                          :whether_business_opportunity => true,
                          :business_opportunity_number => business_opportunity_id,
                          :share_orders_attributes =>share_orders_attributes,
                          :business_opportunity_orders_attributes => [{:business_opportunity_id => business_opportunity.id}]
                         }


    else
      #创建执行订单
      # share_orders_attributes = (share_order_user+ user_id).map{|user| {:share_id=> user}}
      advertisements_attributes = advertisements_from_business_opportunity(business_opportunity_id)

      channel_rebates = client.present? && client.client_channel.present? ? client.client_channel.channel_rebates : []
      order_rebate = 0.00
      channel_rebates.each{|channel_rebate|
        if  deliver_start_date <= channel_rebate.end_date
          order_rebate = channel_rebate.rebate
        break;
        end
      }
      if advertisements_attributes.present?
      order.attributes = {:code =>Order.create_sn,
                          :title => order_title,
                          :start_date=>deliver_start_date,
                          :ending_date=>deliver_end_date,
                          :budget=>budget,
                          :budget_currency=>budget_currency,
                          :client_id=>client_id,
                          :user_id=>user_id,
                          :whether_monitor=>false,
                          :frequency_limit=>false,
                          :client_material=>false,
                          :planner_check=>false,
                          :xmo_code =>false,
                          :free_tag =>"0",
                          :exclude_date => [],
                          :third_monitor_code => "AdMaster",
                          :linkman => client.present? ? client.clientcontact : "",
                          :whether_msa =>exist_msa,
                          :whether_service =>exist_service,
                          :rebate => order_rebate,
                          :whether_business_opportunity => true,
                          :business_opportunity_number => business_opportunity_id,
                          :share_orders_attributes =>share_orders_attributes,
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
    if  order.save!(:validate=>false)
      order.update_columns({:last_update_user=> last_update_user.present? ? last_update_user.name : ""})
      # order.set_business_opportunities_process("order_service_create")
    end
    end
    return order.id,errors_msg


  end

  def self.advertisements_from_business_opportunity(business_opportunity_id)
    business_opportunity = BusinessOpportunity.find business_opportunity_id
    business_opportunity_products = business_opportunity.business_opportunity_products
    budget_currency =  Currency.find(business_opportunity.currency_id).name
    advertisements_attributes = []
    if business_opportunity_products.present?
    business_opportunity_products.each do |buniness_product|
      product = Product.find buniness_product.product_id
      if product.present?
        ad_type = product.product_category ? product.product_category.value : nil
        cost_type = product.sale_model
        public_price = product.public_price.present? ? product.public_price : 0
        discount = product.floor_discount.present? ? product.floor_discount * 100 : 0
        public_price = public_price * (ExchangeRate.get_rate(budget_currency,product.currency))
        cost =  (discount * public_price).round(2)
        product_id = product.id
      end
      advertisement =  {:budget_ratio=> buniness_product.budget,
                        :ad_type => ad_type,
                        :cost_type => cost_type,
                        :cost => cost,
                        :price_presentation=>"",
                        :nonstandard_kpi=>"",
                        :discount =>discount,
                        :product_id =>product_id
      }
      advertisements_attributes << advertisement
    end
    end
    return advertisements_attributes
  end



  #可以预审的订单
  def self.orders_by_pre_check(order_id = nil)
    condition  = " and t.id = #{order_id}" if order_id
    return Order.find_by_sql(" select distinct t.id from (select o.*,s.share_id from orders o left join  share_orders s on o.id = s.order_id ) t ,
                               permissions p where (t.user_id = p.create_user or t.share_id = p.create_user) and p.node_id =1 #{condition}")
  end

  def business_opportunity_code
   (whether_business_opportunity  && business_opportunity_number.present?) ? 'SO'+business_opportunity_number.to_s.rjust(9,'0') : '-'
  end

  #更新订单下所有产品折扣
  def update_all_ads_discount
    self.advertisements.each{|ad| ad.update_discount}
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
      DEFAULTS.each do |k,v| 
        self.send("#{k}=",v)
      end
    end

    def first_find(arr,f)
      j = 0
      arr.each_with_index do |a,i|
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
      arr.reverse.each_with_index do |s,i|
      j = i
      m =s
      break if s > 0
      end
      return 5-j-1,m
    end

end

require_dependency 'order/workflow'
require_dependency 'order/scopes'
