class Advertisement < Base
  include SendOrderAdvertisementClient

  COSTTYPE = ["CPC","CPM", "CPE"].freeze

  serialize :admeasure
  serialize :admeasure_en
  ADCOMBO = {"COMPUTER"=>["VA15","WIN","PIP","MIX","BAN", "QQSpace"],"MOBILE"=>["APPVA15","ACROSS","TABLE","APPMIX", "QQMessage","OTHERTYPE"]}
  FOREIGN_MOBILE_ADCOMBO = ["MobileBannersAndWecat", "InFeedAdvertisingANDQQ","OTHERTYPE"]
  
  CURRENCY = ["RMB","HKD","USD","SGD","TWD","KRW","JPY","MYR","GBP","EUR","AUD","THB","RUB","IDR"].freeze

  REGIONAL = ["EMPTY","SPECIAL","OTHER","NATION", "US_UK_AU_NZ_MY", "HK_TW_MA_SG", "OTHER_COUNTRY","SPECIAL_CITY","SPECIAL_COUNTRY"]

  THE_LOWEST_ADMEASURE = 1000000

  TOP_LIVE_MEDIA = ['新华网','北青网','闺蜜网','yoka']

  RTB_PRICE_RAKE = {"CPC" => [[" _ < 0.6",90],["0.6 <= _ && _ < 0.79",93],["0.8 <= _  && _ < 0.99",95],["1 <= _  && _ < 1.19",100],["1.2 <= _ && _ < 1.49",102],["1.5 <= _  && _< 1.99",108],["_ >= 2",130]],
                    "CPM" => [["_ < 2",90],["2 <= _  && _ < 2.9",100],["3 <= _ && _ < 3.9",103],["4 <= _ && _ < 4.9",119],["5 <= _ && _ < 5.9",130],["6 <= _ && _ < 7.9",142],["8 <= _ && _ < 9.9",157],["10 <= _ && _ < 11.9",120],["_ >= 12",130]]}

  RTB_CTR_RAKE = [["_ < 0.2",94],["0.2 <= _ && _ <0.29",97],["0.3 <= _ && _ <0.39",100],
                  ["0.4 <= _ && _ < 0.49",102],["0.5 <= _ && _ <0.59",105],["0.6 <= _ && _ < 0.79",108],
                  ["0.8 <= _ && _ < 0.99",110],["1 <= _ && _ < 1.19",112],["1.2 <= _ && _ < 1.49",116],["_ == 1.5",118],["_ > 1.5",120]]

  COMPUTER_AD_TYPE = {"VA15" => "Preroll-15s","WIN" => "AdTV","PIP" => "PIP","PC-OTV(15s)" => "Preroll-15s" ,"PC-OTV(30s)" => "Pre-roll-30s"}
  COMPUTER_PV_MEDIA_TYPE = {"Preroll-15s" => "PC-OTV(15s)","AdTV" => "WIN","PIP" => "PIP","Pre-roll-30s" => "PC-OTV(30s)"}

  belongs_to :order, inverse_of: :advertisements, touch:true

  has_many :gps , inverse_of: :advertisement

  belongs_to :product,inverse_of: :advertisements

  accepts_nested_attributes_for :gps, allow_destroy: true

  attr_accessor :order_budget, :order_regional, :order_budget_currency,:city_size,:myplanner,:mycity,:all_myplanner,:all_mycity


  # validates :ad_type,presence: true
  # validates :cost_type, inclusion: { in: COSTTYPE,message: "%{value} is not a valid currency" }, presence: true
  # validates :cost, numericality: {greater_than: 0,less_than:1000}, presence: true
  # validates :budget_ratio, numericality: {greater_than: 0,less_than_or_equal_to:100}, presence: true
  after_create :update_order_columns
  after_save :update_orders
  after_destroy :update_order_columns
  %w{cpm cpc cpe}.each do |_|
    eval %Q(
          def #{_}?
            cost_type == "#{_.upcase}"
          end
      )
  end

  def self.foreign_region?(region)
    ["US_UK_AU_NZ_MY", "HK_TW_MA_SG", "OTHER_COUNTRY"].include?(region)
  end

  def budget_ratio(super_method = nil)
    if super_method
      super().present? ? super().to_f : 0
    else
      (super().present? && order_budget_show.present? ) ? (super().to_f * 100 / order_budget_show) : 0.0
    end
  end

  #所有不需要gp投放的产品类型
  def un_gp_ad_type?
    self.product.present? && (self.product.is_distribute_gp == false || !self.product.is_distribute_gp )
  end

  #所有需要gp投放的产品类型
  def gp_ad_type?
    self.product.present? && self.product.is_distribute_gp == true && (self.order.china_regional? )
  end

  #dsp投放的产品类型
  def dsp_gp_ad_type?
    self.product.present? && self.product.is_distribute_gp == true && (self.order.china_regional? ) && self.product.product_gp_type == "DSP"
  end

  #非dsp投放的产品类型
  def un_dsp_gp_ad_type?
    self.product.present? && self.product.is_distribute_gp == true and self.product.product_gp_type != "DSP"
  end

  #获取产品排序
  def get_advertisements_live
    advertisement_ids = self.order.advertisement_ids
    return "产品"+(advertisement_ids.index(self.id)+1).to_s+": "
  end

  #售价区间成本浮动率
  def get_rtb_price_rake
    return_rtb_rake = 0
    RTB_PRICE_RAKE[self.cost_type].each do |rtb_rake|
      _ = self.cost
      if eval(rtb_rake[0])
        return_rtb_rake = rtb_rake[1]
        break
      end
    end
    return return_rtb_rake
  end

  #CTR成本浮动率
  def get_rtb_ctr_rake
    return_rtb_rake = 0
    RTB_CTR_RAKE.each do |rtb_rake|
      _ = self.forecast_ctr
      if eval(rtb_rake[0])
        return_rtb_rake = rtb_rake[1]
        break
      end
    end
    return return_rtb_rake
  end

  #获取rtb城市买价
  def meida_rtb_price(city = nil)
    cost_type = self.cost_type.downcase
    if (!city || city == "-")
      media_send_city = self.order.media_send_city
      if media_send_city == "全国通投"
        price = 0.3 
      elsif media_send_city == "按省投放"
        price = 0.4 
      else
        citys = media_send_city.split
        if citys.size < 10 && (citys & ["北京","上海","广州","深圳"]).size > 0
          price = 0.48 
        else
          price = 0.4 
        end
      end
    else
      dsp_city_price = DspTrafficPrice.find_by_sql("select #{cost_type}_price price from dsp_traffic_prices where city = '#{city}' " )
      price = dsp_city_price.present? ? dsp_city_price[0]["price"] : ""
    end
    return price
  end

  #获取rtb类型广告的CPM/CPC买价
  def get_average_cost(city = nil)
    (self.meida_rtb_price(city)) * (self.get_rtb_price_rake.to_f / 100) * (self.get_rtb_ctr_rake.to_f / 100)
  end

  #删除产品地市gp记录
  def delete_advertisement_gps(city = nil)
    Gp.connection.delete "delete from gps where advertisement_id = #{self.id} and city = '#{city}' "
  end

  #删除产品gp未提交记录
  def delete_advertisement_unsave_gps
    Gp.connection.delete "delete from gps where advertisement_id = #{self.id} and save_flag = 0"
  end

  #删除产品gp记录

  def delete_advertisement_all_gps
    Gp.connection.delete "delete from gps where advertisement_id = #{self.id}"
  end

  #(配送点击成本×配送点击量)
  # (1) 一线城市：0.4 RMB
  # (2) 其他城市 或 全国：0.3 RMB
  # 对一线城市 或 其他城市 的判断方法同判断底价采用逻辑一致。
  def planner_clicks_cost

    self.planner_clicks && self.product && self.product.product_regional  ? (self.planner_clicks * (self.product.product_regional.value == "SPECIAL" ? 0.4 : 0.3 ) ) : 0
  end

  #是否按地市分配
  def have_admeasure_map?
    (self.admeasure_state == '1' && self.admeasure.present?)
  end

  #获取所有地域分配
  def admeasures
    have_admeasure_map? ? self.admeasure[0..-2].select{|f| f[1].to_i > 0 } : []
  end

  #是否按地市分配
  def have_admeasure_map?
    (self.admeasure_state == '1' && self.admeasure.present? && (self.admeasure[0..-2].select{|f| f[1].to_i > 0 }.size > 0) )
  end

  #按地市分配未分配完成的城市
  def get_advertisement_unfinish_citys
    unfinish_admeasure_map = []
    if self.have_admeasure_map?
      self.admeasures.each do |admeasure|
        unfinish_admeasure_map << admeasure[0] if self.gps.where("city = ? and save_flag = ?",admeasure[0],true).map(&:pv_config_scale).inject( 0 ) {|sum, i| sum+i.to_f }.round(2)  != 100
      end
    end
    return unfinish_admeasure_map
  end

  def book_sql
    ad_type = self.product.product_xmo_type #Advertisement::COMPUTER_AD_TYPE[self.ad_type]
    if self.product.product_gp_type == "MIX"
      ad_type ="'PIP','AdTV'"
    else
      ad_type = "'#{ad_type}'"
    end
    if self.have_admeasure_map? #有地市分配
      citys =self.get_advertisement_unfinish_citys
      province = citys  &  ProvinceCode.province_name
      un_province_city = citys - province
      if un_province_city.present?
      city = un_province_city.map{|c| "'"+c+"市'"}.join(",")
      else
      city = 'NULL'
      end

      sql="select average_cost_cpm,id,placement_id,city,media,media_type,midia_form,replace(ad_original_size,'*','×') as ad_original_size,replace(ad_expand_size,'*','×') as ad_expand_size,ctr,day_pv as sum_pv from pv_details where midia_form in (#{ad_type}) and city in (#{city}) and average_cost_cpm >0 "

      province.each{|province|
      province_city = province_city_name(province)
      sql += "union all select  t1.average_cost_cpm,t4.* from (select placement_id,media,average_cost_cpm from pv_details where city = '按省投放' and  midia_form in (#{ad_type}) and average_cost_cpm >0) t1 left join
         (select t2.*  from
         (select id,placement_id,'#{province}' as city,media,media_type,midia_form,replace(ad_original_size,'*','×') as ad_original_size,replace(ad_expand_size,'*','×') as ad_expand_size,ctr, sum(day_pv) as sum_pv  from pv_details where average_cost_cpm >0 and midia_form in (#{ad_type}) and city in (#{province_city}) group by media,ctr) t2
          where t2.sum_pv=(select max(t3.sum_pv) from (select media,sum(day_pv) as sum_pv  from pv_details where average_cost_cpm >0 and midia_form in (#{ad_type}) and city in (#{province_city}) group by media,ctr) t3 where t2.media=t3.media)) t4
          on t1.placement_id=t4.placement_id"
      }

     #目前没有 MIX和DSP 产品，暂时注释掉
      # if self.product.product_gp_type == "MIX"
      #   citys.each do |city|
      #     mix_media_cpm = self.get_average_cost(city)
      #     sql +=" union select '0','-','#{city}市','RTB','NA','Dsp','NA','NA','-',#{mix_media_cpm},'-' from dual"
      #   end
      # end
    else #产品不按地市分配预算
      media_send_city = self.order.media_send_city
      if media_send_city != ""
      if media_send_city == "全国通投" #全国投放

        sql= "select  t1.average_cost_cpm,t4.* from (select placement_id,media,average_cost_cpm from pv_details where city = '全国通投' and  midia_form in (#{ad_type}) and average_cost_cpm >0) t1 left join
        (select t2.*  from
        (select id,placement_id,'-' as city,media,media_type,midia_form,replace(ad_original_size,'*','×') as ad_original_size,replace(ad_expand_size,'*','×') as ad_expand_size,ctr, sum(day_pv) as sum_pv  from pv_details where average_cost_cpm >0 and midia_form in (#{ad_type})  group by media,ctr) t2
         where t2.sum_pv=(select max(t3.sum_pv) from (select media,sum(day_pv) as sum_pv  from pv_details where average_cost_cpm >0 and midia_form in (#{ad_type})  group by media,ctr) t3 where t2.media=t3.media)) t4
         on t1.placement_id=t4.placement_id"

      elsif media_send_city == "按省投放" #按省投放

        city = self.order.order_city_name(true).split(",").map{|c| "'"+c+"市'"}.join(",")
        sql = "select  t1.average_cost_cpm,t4.* from (select placement_id,media,average_cost_cpm from pv_details where city = '按省投放' and  midia_form in (#{ad_type}) and average_cost_cpm >0) t1 left join
         (select t2.*  from
         (select id,placement_id,'-' as city,media,media_type,midia_form,replace(ad_original_size,'*','×') as ad_original_size,replace(ad_expand_size,'*','×') as ad_expand_size,ctr, sum(day_pv) as sum_pv  from pv_details where average_cost_cpm >0 and midia_form in (#{ad_type}) and city in (#{city}) group by media,ctr) t2
          where t2.sum_pv=(select max(t3.sum_pv) from (select media,sum(day_pv) as sum_pv  from pv_details where average_cost_cpm >0 and midia_form in (#{ad_type}) and city in (#{city}) group by media,ctr) t3 where t2.media=t3.media)) t4
          on t1.placement_id=t4.placement_id"

      else #无地市分配,订单有地市
        city = self.order.order_city_name(true).split(",").map{|c| "'"+c+"市'"}.join(",")
        sql = "select t3.average_cost_cpm,t6.* from  (
        select t1.average_cost_cpm,t1.media from ( select media,average_cost_cpm from pv_details where average_cost_cpm >0 and city in (#{city})  and  midia_form in (#{ad_type})  group by media, average_cost_cpm) t1 where t1.average_cost_cpm =(select max(t2.average_cost_cpm) from (select media,average_cost_cpm from pv_details
         where average_cost_cpm >0 and city in (#{city})  and  midia_form in (#{ad_type}) group by media, average_cost_cpm) t2 where t1.media=t2.media)
         ) t3 left join
         (select t4.*  from
         (select id,placement_id,'-' as city,media,media_type,midia_form,replace(ad_original_size,'*','×') as ad_original_size,replace(ad_expand_size,'*','×') as ad_expand_size,ctr, sum(day_pv) as sum_pv  from pv_details where average_cost_cpm >0 and midia_form in (#{ad_type}) and city in (#{city}) group by media,ctr) t4
          where t4.sum_pv=(select max(t5.sum_pv) from (select media,sum(day_pv) as sum_pv  from pv_details where average_cost_cpm >0 and midia_form in (#{ad_type}) and city in (#{city}) group by media,ctr) t5 where t4.media=t5.media)) t6
          on t3.media=t6.media"
      end
      #目前没有 MIX和DSP 产品，暂时注释掉
      # if self.product.product_gp_type == "MIX" #self.ad_type == "MIX" || self.ad_type == "PC-Richmedia"
      #   mix_media_cpm = self.get_average_cost
      #   sql +=" union select #{mix_media_cpm},'0','','-','DSP','RTB','DSP','NA','NA','','' from dual"
      # end
      end
    end
    return sql
  end

  #某个省下所有城市解析
  def province_city_name(province_name)
    city = LocationCode.find_by_sql("select city_name_cn from location_codes where province_id in (select code_id from province_codes where name_cn = '#{province_name}')")
    return city.map{|c| "'"+c["city_name_cn"]+"市'"}.join(",")
  end


  #按地市分配已分配完成的城市
  def get_advertisement_finish_citys
    finish_admeasure_map = []
    if self.have_admeasure_map?
      self.admeasures.each do |admeasure|
        finish_admeasure_map << admeasure if self.gps.where("city = ? and save_flag = ?",admeasure[0],true).map(&:pv_config_scale).inject( 0 ) {|sum, i| sum+i.to_f }.round(2)  == 100
      end
    end
    return finish_admeasure_map
  end

  #是否所有订单产品媒体GP已分配完
  def any_not_advertisement_gp_finish?
    if self.have_admeasure_map?
      #每个城市都已分配，且都够100%
      finish_admeasure_map = true
      self.admeasures.each do |admeasure|
        finish_admeasure_map = false if self.gps.where("city = ? and save_flag = ? ",admeasure[0],true).map(&:pv_config_scale).inject( 0 ) {|sum, i| sum+i.to_f }.round(2)  != 100
      end
      return finish_admeasure_map
    else
      #不按城市分配，已分配，且够100%
      self.gps.where("save_flag = ? ",true).map(&:pv_config_scale).inject( 0 ) {|sum, i| sum+i.to_f }.round(2)  == 100
    end
  end

  #已分配地域GP
  def get_admeasure_gps(admeasure)
    admeasure_gps = 0.00
    self.gps.where("city = ?",admeasure[0]).each do |gp|
      admeasure_gps += gp.gp
    end
    admeasure_gps = admeasure_gps - planner_clicks_cost * (admeasure[1].to_f/ self.budget_ratio("super"))
    return admeasure_gps
  end

  #已分配地域GP%
  def get_admeasure_gps_rake(city)
    admeasure = get_admeasure_array(city)
    get_admeasure_gps(admeasure) / ( self.order.budget.to_f * (self.budget_ratio.to_f / 100.00) * (admeasure[1].to_f / self.budget_ratio("super")) )
  end

  #已分配地域总cpm/cpc
  def get_admeasure_gps_total_price(city)
    ( 1 - get_admeasure_gps_rake(city) ) * self.cost.to_f
  end

  #已分配产品GP
  def get_advertisement_gps
    advertisement_gps = 0.00
    if self.have_admeasure_map?
      self.get_advertisement_finish_citys.each do |admeasure|
        advertisement_gps += get_admeasure_gps(admeasure)
      end
    else
      self.gps.each do |gp|
        advertisement_gps += gp.gp
      end
      advertisement_gps = advertisement_gps - planner_clicks_cost
    end
    return advertisement_gps
  end

  #已分配产品GP%
  def get_advertisement_gps_rake
    get_advertisement_gps / ( self.order.budget.to_f * (self.budget_ratio.to_f / 100.00) )
  end

  #已分配产品总cpm/cpc
  def get_advertisement_gps_total_price
    (1 - get_advertisement_gps_rake) * self.cost
  end

  #当前正处理的gps
  def current_gps(city = nil)
    if (!city || city == "-")
      @lgps = Gp.where("advertisement_id = ? ",self.id )
    else
      @lgps = Gp.where("advertisement_id = ? and city = ? ",self.id, city)
    end
  end

  #当前分配GP
  def current_send_gps(city = nil)
    advertisement_gps = 0.00
    if (!city || city == "-")
      lgps = Gp.where("advertisement_id = ? ",self.id )
      lgps.each do |gp|
        advertisement_gps += gp.get_gp
      end
      advertisement_gps = advertisement_gps - self.planner_clicks_cost
    else
      admeasure = get_admeasure_array(city)
      lgps = Gp.where("advertisement_id = ? and city = ? ",self.id, city)
      lgps.each do |gp|
        advertisement_gps += gp.get_gp
      end
      advertisement_gps = advertisement_gps - self.planner_clicks_cost.to_f * (admeasure[1].to_f/ self.budget_ratio("super"))
    end
    return advertisement_gps
  end

  #当前分配GP%
  def current_send_gps_rake(city)
    if (!city || city == "-")
      gps_rake = (self.current_send_gps(city) / ( self.order.budget.to_f * (self.budget_ratio.to_f / 100.00) ))
    else
      admeasure = get_admeasure_array(city)
      gps_rake = (self.current_send_gps(city) / ( self.order.budget.to_f * (self.budget_ratio.to_f / 100.00) * (admeasure[1].to_f/ self.budget_ratio("super")) ))
    end
    return gps_rake
  end

  #当前分配GP 50%判断
  def get_current_gps_rake_50?(city = nil)
    self.current_send_gps_rake(city) < 50/100.00
  end

  #计算优先权重
  def priority_weight_live
    @defaule_weight_gps = @lgps.where("media in (?)", TOP_LIVE_MEDIA )
    @undefaule_weight_gps = @lgps.where("media not in (?)", TOP_LIVE_MEDIA )
    
    gps_group_by_price = @undefaule_weight_gps.order("average_cost_cpm desc").group_by(&:average_cost_cpm)

    live = 0
    @total_weight_live = 0
    @gp_weight_lives = {}

    gps_group_by_price.each do |k,v|
      live += 1
      v.each do |vv|
        @gp_weight_lives[vv.id.to_s] = live
        @total_weight_live += live
      end
    end

    @defaule_weight_gps.each do |vv|
      live += 1
      @gp_weight_lives[vv.id.to_s] = live 
      @total_weight_live += live
    end
  end

  #查找城市分配量
  def get_admeasure_array(city)
    self.admeasures.select{ |aa| aa[0] == "#{city}" }[0]
  end

  #总需求展现量/点击量
  def total_cpm_show(city = nil)
    if self.have_admeasure_map? && (city || city != "-")
      admeasure = get_admeasure_array(city)
      (( self.order.budget.to_f * (self.budget_ratio.to_f / 100.00) ) * (admeasure[1].to_f/ self.budget_ratio("super")) * (self.cost_type == "CPM" ? 1000 : 1) ) / self.cost.to_f
    else
      (( self.order.budget.to_f * (self.budget_ratio.to_f / 100.00) ) * (self.cost_type == "CPM" ? 1000 : 1) ) / self.cost.to_f if self.budget_ratio.present? && self.cost.present?
    end
  end

  #自动分配媒体最低下限
  def ad_lowest_pv(city = nil)
    if self.have_admeasure_map? && (city || city != "-")
      admeasure = get_admeasure_array(city)
      THE_LOWEST_ADMEASURE * (admeasure[1].to_f / self.budget_ratio("super"))
    else
      THE_LOWEST_ADMEASURE
    end
  end

  #判断需分配的媒体数是否太多，待分配媒体数* 分配下限 > 总需求展现量
  def whether_overproof?
    @lgps.size * @lowest_pv > @total_cpm_show
  end

  #自动分配媒体流量
  def auto_distribution(city = nil)
    current_gps(city)
    priority_weight_live
    @lowest_pv = (ad_lowest_pv(city)/1000).to_f
    @total_cpm_show = (total_cpm_show(city)/1000).to_f
    if self.gps.present?
      if @total_cpm_show < @lowest_pv
        auto_distribution3
      else
        if whether_overproof?
          auto_distribution0
        else
          auto_distribution1
          if get_current_gps_rake_50?(city)
            auto_distribution2
          end
        end
      end
    end
    return @return_auto_source
  end

  #自动分配保存
  #确保分配100%
  def auto_gp_save
    total_gp_3 = 0.00
    total_gp_4 = 0
    @return_auto_source.each_with_index do |gp,i|
      gp[3] = (gp[3]*100).round(2)
      gp[4] = gp[4].round

      if ( i == @return_auto_source.size - 1 ) && ( (total_gp_3 + gp[3] != 100.00) || (total_gp_4 + gp[4] != @total_cpm_show ) )
         gp[3] = 100 - total_gp_3.round(2)
         gp[4] = @total_cpm_show - total_gp_4
      end

      total_gp_3 += gp[3]
      total_gp_4 += gp[4]

      lgp = Gp.find gp[-1]
      lgp.pv_config_scale = gp[3]
      lgp.pv_config = gp[4]
      lgp.save!
    end
  end

  #自动分配算法0
  #若需分配的媒体数太多，待分配媒体数* 分配下限 > 总需求展现量时，仅分配至成本最低的 前 N个媒体。
  # N = INT( 总需求展现量/单个媒体分量下限 )
  def auto_distribution0
    p "00000000000000000000000000"
    n = (@total_cpm_show / @lowest_pv).to_i
    @return_auto_source = []
    total_cpm = @total_cpm_show

    @auto_source = @lgps.collect{|gp|[gp.media_id,@lowest_pv,@gp_weight_lives[gp.id.to_s],nil,nil,gp.id]}.sort_by{|a| [a[2]] }.reverse[0..n-1]
    @auto_source_n = @lgps.collect{|gp|[gp.media_id,@lowest_pv,@gp_weight_lives[gp.id.to_s],0,0,gp.id]}.sort_by{|a| [a[2]] }.reverse[n..-1]

    if @auto_source
      @auto_source.each_with_index do |gp,i|
        gp[4] = @lowest_pv
        total_cpm = total_cpm - @lowest_pv
      end
    end

    max_live = @gp_weight_lives.values.max
    max_live_size = @auto_source.select{|gp| gp[2] == max_live}.size
    @auto_source.each do |gp|
      if gp[2] == max_live
        gp[4] +=  total_cpm / max_live_size
      end
    end

    @auto_source.each do |gp|
      gp[3] = gp[4] / @total_cpm_show.to_f
      @return_auto_source << gp
    end

    if @auto_source_n
      @auto_source_n.each do |gp|
        @return_auto_source << gp
      end
    end
    
    auto_gp_save
  end


  #自动分配算法1
  #低于下限时，取下限，并重新计算剩余比例
  def auto_distribution1
    p "111111111111111111111"
    @return_auto_source = []
    @auto_source = @lgps.collect{|gp|[gp.media_id,@lowest_pv,@gp_weight_lives[gp.id.to_s],nil,nil,gp.id]}.sort_by{|a| [a[2]] }.reverse

    total_cpm = @total_cpm_show
    min_live = 1

    all_live = @total_weight_live.to_f

    while total_cpm > 0
      #判断当前最小权重是否会不足最低量
      if (min_live / all_live.to_f) * total_cpm > @lowest_pv
        @auto_source.each do |gp|
          gp[4] = ( gp[2] / all_live ) * total_cpm
          @return_auto_source << gp
        end
        total_cpm = 0
      else
        #低于下限的时候，所有最低等级的都取下限
        min_auto = @auto_source.select{|gp| gp[2] == min_live }
        min_auto.each{|gp| gp[4] = @lowest_pv}

        total_cpm = total_cpm - @lowest_pv * min_auto.size
        all_live = all_live - min_live * min_auto.size

        min_auto.each do |gp|
          @return_auto_source << gp
          @auto_source.delete(gp)
        end

      end
      min_live = @auto_source.collect{|gp| gp[2] }.min
    end

    @return_auto_source.each do |gp|
      gp[3] = gp[4] / @total_cpm_show.to_f
    end

    auto_gp_save
  end

  #自动分配算法2
  #若生成后GP% < 50，则采用GP最优分配方法
  # (a) 先为每个媒体分配下限展示量
  # (b) 将剩余待分配展示量集中至成本最低的媒体
  def auto_distribution2
    p "22222222222222222222222"
    @auto_source = @lgps.collect{|gp|[gp.media_id,@lowest_pv,@gp_weight_lives[gp.id.to_s],nil,nil,gp.id]}.sort_by{|a| [a[2]] }.reverse
    total_cpm = @total_cpm_show

    @auto_source.each do |gp|
      gp[4] = @lowest_pv
      total_cpm = total_cpm - @lowest_pv
    end

    max_live = @gp_weight_lives.values.max
    max_live_size = @auto_source.select{|gp| gp[2] == max_live}.size
    @auto_source.each do |gp|
      if gp[2] == max_live
        gp[4] +=  total_cpm / max_live_size
      end
    end

    @auto_source.each do |gp|
      gp[3] = gp[4] / @total_cpm_show.to_f
    end

    @return_auto_source = @auto_source
    auto_gp_save
  end

  #自动分配算法3 
  #pv总量小于最低pv下限量
  def auto_distribution3
    @return_auto_source = []
    @auto_source = @lgps.collect{|gp|[gp.media_id,@lowest_pv,@gp_weight_lives[gp.id.to_s],nil,nil,gp.id]}.sort_by{|a| [a[2]] }.reverse[0]
    @auto_source_n = @lgps.collect{|gp|[gp.media_id,@lowest_pv,@gp_weight_lives[gp.id.to_s],0,0,gp.id]}.sort_by{|a| [a[2]] }.reverse[1..-1]

    if @auto_source
      @auto_source[4]= @total_cpm_show
      @auto_source[3] = 1
      @return_auto_source << @auto_source
    end

    if @auto_source_n
      @auto_source_n.each do |gp|
        @return_auto_source << gp
      end
    end
    auto_gp_save
  end
 
  def currency_rate
     ExchangeRate.get_rate(self.budget_currency_show, self.product.currency)
  end

  def budget_currency_show
    self.id.present? ? self.order.budget_currency : (self.order_budget_currency.present? ? self.order_budget_currency : "RMB")
  end

  def discount
    (super().nil? or super()==0) ? 100.00 : super().to_f
  end

  def discount_show
    100
  end



  def budget_ratio_show
    self.budget_ratio("super").present? ? self.budget_ratio("super").to_f : 0
  end

  def budget
     if !self.order_budget_show.nil_zero? && !budget_ratio.nil_zero?
       self.order_budget_show * (budget_ratio.to_f / 100)
     else
       0.0
     end
  end

  def order_budget_show
    (self.id.present? && !self.order.budget.nil_zero?) ? self.order.budget : (self.order_budget.present? ? self.order_budget.to_f : nil)
  end

  def promise_hits(city_budget_distribution = 1)
    if cpc? && cost.to_f != 0
      ( budget.to_f * city_budget_distribution / (cost * discount_show / 100)).round
    else
      return 0
    end
  end

  def promise_cpc
    if cpc? && cost.to_f != 0
      cost * discount_show / 100
    else
      return 0
    end
  end

  def promise_cpe
    if cpe? && cost.to_f != 0
      cost * discount_show / 100
    else
      return 0
    end
  end

  def promise_exposure(city_budget_distribution = 1)
    if cpm? && cost.to_f != 0
      ((budget.to_f * 1000 * city_budget_distribution) / (cost.to_f * discount_show / 100)).round
    else
      return 0
    end
  end

  def promise_cpm
    if cpm?
      cost * discount_show / 100
    else
      return 0
    end
  end

  def total_price(city_budget_distribution = 1)
    if public_price
      if cpm?
        public_price * promise_exposure(city_budget_distribution) / 1000
      else
        public_price * (budget.to_f * city_budget_distribution / (cost * discount_show / 100)).to_i
      end
    end
  end

  def daily_exposure(city_budget_distribution = 1)
    promise_exposure(city_budget_distribution) / self.order.period
  end

  def daily_hits(city_budget_distribution = 1)
    promise_hits(city_budget_distribution) / self.order.period
  end

  # 日均预估曝光数
  def daily_impressions_prediction(city_budget_distribution = 1)
    return  impressions_prediction(city_budget_distribution).present? ?  impressions_prediction(city_budget_distribution) / self.order.period : 0
  end

  # 日均预估点击数
  def daily_clicks_prediction(city_budget_distribution = 1)
    clicks_prediction(city_budget_distribution) / self.order.period rescue 0
  end

  def cpe_times(city_budget_distribution = 1)
    return (budget.to_f * city_budget_distribution / (cost * discount_show / 100)).to_i if (offer || other_product?) and cpe? and !budget.nil_zero? and !cost.nil_zero?
  end

  # 预估曝光数
  def impressions_prediction(city_budget_distribution = 1)
    return (budget.to_f * 1000 * city_budget_distribution / (cost.to_f * discount_show / 100)).round if (offer || other_product?) and cpm? and !budget.nil_zero? and !cost.nil_zero?
    return (clicks_prediction(city_budget_distribution).to_f / (forecast_ctr / 100)).round if (offer || other_product?) and cpc? and !budget.nil_zero? and !cost.nil_zero? and ((!offer.nil? and forecast_ctr!=0 and !clicks_prediction.nil?) or after_other_ctr? )
  end

  # 预估点击数
  def clicks_prediction(city_budget_distribution = 1)
    return (budget.to_f * city_budget_distribution / (cost.to_f * discount_show / 100)).to_i if (offer || other_product?) and cpc? and !cost.nil_zero? and !budget.nil_zero?
    return (impressions_prediction(city_budget_distribution) * (forecast_ctr / 100)).to_i if (offer || other_product?) and cpm? and !budget.nil_zero? and !cost.nil_zero? and ( !offer.nil? or after_other_ctr? ) and !impressions_prediction.nil?
  end

  # 预估CPC
  def cpc_prediction
    return (self.cost * discount_show / 100)/1000/(forecast_ctr / 100) if (offer || other_product?) and cpm? and !cost.nil_zero?
  end

  # 预估CPM
  def cpm_prediction
    return  1000 * (forecast_ctr / 100) * (self.cost * discount_show / 100) if (offer || other_product?) and cpc? and !cost.nil_zero?
  end

  def cost_can?
    cost_price = nil
    if self.planner_clicks.present? # && !Advertisement.foreign_region?(self.order_regional_show)
      cost_price = ((budget.to_f - click_price) * cost) / budget.to_f if !cost.nil_zero? and !budget.nil_zero? and !click_price.nil_zero?
    else
      cost_price = cost * discount_show / 100 if cost.present?
    end
    cost_price.round(2) >= floor_price.round(2) if cost_price.present? and floor_price.present?
  end

  def click_price
    cpc_floor_price * self.planner_clicks unless (planner_clicks.nil? || ( offer.nil? && !other_product? ) )
  end

  def cpc_offer
    self.product
  end

  def offer
    @offer ||= self.product
  end

  def cpc_public_price
    cpc_offer.public_price  * currency_rate unless cpc_offer.nil?
  end

  def cpc_floor_price
    cpc_offer.public_price * cpc_offer.floor_discount unless cpc_offer.nil?
  end

  def public_price
    offer.public_price  * currency_rate unless offer.nil? || offer.public_price.nil?
  end

  def general_price
    self.public_price * offer.floor_discount unless offer.nil?
    #self.public_price * offer.general_discount unless offer.nil?
  end

  def floor_price
    self.public_price * offer.floor_discount unless offer.nil? || self.public_price.nil?
  end

  def underpraise?
    if special_ad?
      true
    else
      floor_price_v = floor_price
      if cost and floor_price_v
        cost * discount_show / 100 < floor_price_v
      else
        false
      end
    end
  end

  def nonstandard?
    self.order.planner_check or nonstandard_kpi.present?
  end

  def other_product?
    self.ad_type == "OTHERTYPE"
  end

  def special_ad?
    other_product? or (self.order && self.order.id && self.order.id > 834 && self.order.regional == "SPECIAL_COUNTRY")
  end

  def before_other_ctr?
    (self.planner_ctr.nil? and self.special_ad? )
  end

  def after_other_ctr?
    (self.planner_ctr.present? and self.special_ad? )
  end

  def forecast_ctr
    self.planner_ctr.present? ? self.planner_ctr : offer ? offer.ctr_prediction : ""
  end

  def diff_ctr?
    if offer.present?
      self.planner_ctr.present? && (self.planner_ctr != offer.ctr_prediction ||special_ad? )
    else
      self.planner_ctr.present? && special_ad?
    end
  end

  # def admeasure_miss_100?
  #   !self.admeasure_state.present? || (self.admeasure and self.admeasure.last[1].to_i == 100)
  # end

  # 由预算占比改为预算金额
  def admeasure_miss_100?
    !self.admeasure_state.present? || (self.admeasure and self.admeasure.last[1].to_f == self.budget_ratio("super"))
  end

  #产品询价&询量审批团队是否包含当前用户
  def in_product_approval_team?(user_id)
     if !self.product 
       true
     else
       User.with_groups(self.product.approval_team.to_i).include? user_id.to_i
     end  
  end
  
  #产品执行团队是否包含当前用户
  def in_product_executive_team?(user_id)
    if !self.product 
       true
     else
       User.with_groups(self.product.executive_team.to_i).include? user_id.to_i
     end  
  end

  def self.all_advertisements
    Advertisement.find_by_sql("select a.*,p.name from advertisements a left join products p on a.product_id = p.id").group_by(&:order_id)
  end

  #产品的预估gp%
  def est_gp
    if self.change_gp
        self.change_gp.to_f
    elsif  self.product && self.product.gp
       self.product.gp.to_f
    else
      0.0
    end
  end

  #产品预估gp值
  def est_gp_value
    self.budget_ratio("super").present? ? self.budget_ratio("super").to_f * self.est_gp / 100 : 0.0
  end

  #产品关键字段修改时触发
  def update_ad_examinations_status(origin_ad,current_user)
    key1 = origin_ad.cost != self.cost
    key2 = origin_ad.budget_ratio.to_f != self.budget_ratio.to_f
    key3 = origin_ad.admeasure != self.admeasure
    key4 = origin_ad.ad_type != self.ad_type
    key5 = origin_ad.product_id != self.product_id
    key6 = origin_ad.nonstandard_kpi.to_s != self.nonstandard_kpi.to_s
    key_word_update = false
    if(key1 || key2 || key3 || key4 || key5 || key6)
      order = self.order
      key_word_update = true if order.present?
      order.change_examinations_status(current_user,'Order')
      self.delete_advertisement_all_gps  if order.present?
      order.update_order_columns if order.present?
    end
    return key_word_update
  end


  #订单修改货币单位后重新计算产品折扣
  def update_discount
    self.update_columns(:discount => recount)
  end

  def recount
    (cost * 100 / public_price.round(2)).round(2)  rescue 0.0
  end
  
end
