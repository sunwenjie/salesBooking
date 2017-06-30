class Advertisement < Base

  include Concerns::SendOrderClient

  belongs_to :order, inverse_of: :advertisements, touch: true

  belongs_to :product, inverse_of: :advertisements

  attr_accessor :order_budget, :order_regional, :order_budget_currency, :city_size, :myplanner, :mycity, :all_myplanner, :all_mycity

  after_create :update_order_columns
  after_save :update_orders
  after_destroy :update_order_columns

  serialize :admeasure
  serialize :admeasure_en

  %w{cpm cpc cpe}.each do |_|
    eval %Q(
          def #{_}?
            cost_type == "#{_.upcase}"
          end
      )
  end


  def budget_ratio(super_method = nil)
    if super_method
      super().present? ? super().to_f : 0
    else
      (super().present? && order_budget_show.present?) ? (super().to_f * 100 / order_budget_show) : 0.0
    end
  end

  # #(配送点击成本×配送点击量)
  # # (1) 一线城市：0.4 RMB
  # # (2) 其他城市 或 全国：0.3 RMB
  # # 对一线城市 或 其他城市 的判断方法同判断底价采用逻辑一致。
  # def planner_clicks_cost
  #   self.planner_clicks && self.product && self.product.product_regional  ? (self.planner_clicks * (self.product.product_regional.value == "SPECIAL" ? 0.4 : 0.3 ) ) : 0
  # end

  # #是否按地市分配
  # def have_admeasure_map?
  #   (self.admeasure_state == '1' && self.admeasure.present?)
  # end

  #获取所有地域分配
  def admeasures
    have_admeasure_map? ? self.admeasure[0..-2].select { |am| am[1].to_i > 0 } : []
  end

  #是否按地市分配
  def have_admeasure_map?
    (self.admeasure_state == '1' && self.admeasure? && (self.admeasure[0..-2].select { |am| am[1].to_i > 0 }.size > 0))
  end


  def currency_rate
    ExchangeRate.get_rate(self.budget_currency_show, self.product.currency)
  end

  def budget_currency_show
    self.id? ? self.order.budget_currency : (self.order_budget_currency.present? ? self.order_budget_currency : 'RMB')
  end

  def discount
    (super().nil? or super()==0) ? 100.00 : super().to_f
  end

  def discount_show
    100
  end

  def budget_ratio_show
      budget_ratio('super')
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
      (budget.to_f * city_budget_distribution / (cost * discount_show / 100)).round
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
    return impressions_prediction(city_budget_distribution).present? ? impressions_prediction(city_budget_distribution) / self.order.period : 0
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
    return (clicks_prediction(city_budget_distribution).to_f / (forecast_ctr / 100)).round if (offer || other_product?) and cpc? and !budget.nil_zero? and !cost.nil_zero? and ((!offer.nil? and forecast_ctr!=0 and !clicks_prediction.nil?) or after_other_ctr?)
  end

  # 预估点击数
  def clicks_prediction(city_budget_distribution = 1)
    return (budget.to_f * city_budget_distribution / (cost.to_f * discount_show / 100)).to_i if (offer || other_product?) and cpc? and !cost.nil_zero? and !budget.nil_zero?
    return (impressions_prediction(city_budget_distribution) * (forecast_ctr / 100)).to_i if (offer || other_product?) and cpm? and !budget.nil_zero? and !cost.nil_zero? and (!offer.nil? or after_other_ctr?) and !impressions_prediction.nil?
  end

  # 预估CPC
  def cpc_prediction
    return (self.cost * discount_show / 100)/1000/(forecast_ctr / 100) if (offer || other_product?) and cpm? and !cost.nil_zero?
  end

  # 预估CPM
  def cpm_prediction
    return 1000 * (forecast_ctr / 100) * (self.cost * discount_show / 100) if (offer || other_product?) and cpc? and !cost.nil_zero?
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
    cpc_floor_price * self.planner_clicks unless (planner_clicks.nil? || (offer.nil? && !other_product?))
  end

  def cpc_offer
    self.product
  end

  def offer
    @offer ||= self.product
  end

  def cpc_public_price
    cpc_offer.public_price * currency_rate unless cpc_offer.nil?
  end

  def cpc_floor_price
    cpc_offer.public_price * cpc_offer.floor_discount unless cpc_offer.nil?
  end

  def public_price
    offer.public_price * currency_rate unless offer.nil? || offer.public_price.nil?
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
    self.ad_type == 'OTHERTYPE'
  end

  def special_ad?
    other_product? or (self.order  && self.order.id > 834 && self.order.regional == 'SPECIAL_COUNTRY')
  end

  def before_other_ctr?
    (self.planner_ctr and self.special_ad?)
  end

  def after_other_ctr?
    (self.planner_ctr and self.special_ad?)
  end

  def forecast_ctr
    self.planner_ctr ? self.planner_ctr : offer ? offer.ctr_prediction : ""
  end

  def diff_ctr?
    if offer.present?
      self.planner_ctr && (self.planner_ctr != offer.ctr_prediction ||special_ad?)
    else
      self.planner_ctr && special_ad?
    end
  end

  # 由预算占比改为预算金额
  def admeasure_miss_100?
    !self.admeasure_state.present? || (self.admeasure and self.admeasure.last[1].to_f == self.budget_ratio("super"))
  end

  #产品的预估gp%
  def est_gp
    if self.change_gp
      self.change_gp.to_f
    elsif self.product && self.product.gp
      self.product.gp.to_f
    else
      0.0
    end
  end

  #产品预估gp值
  def est_gp_value
    self.budget_ratio('super').present? ? self.budget_ratio('super').to_f * self.est_gp / 100 : 0.0
  end


  #产品关键字段修改时触发
  def update_ad_examinations_status?(origin_ad, current_user)
    key1 = origin_ad.cost != self.cost
    key2 = origin_ad.budget_ratio.to_f != self.budget_ratio.to_f
    key3 = origin_ad.admeasure != self.admeasure
    key4 = origin_ad.ad_type != self.ad_type
    key5 = origin_ad.product_id != self.product_id
    key6 = origin_ad.nonstandard_kpi.to_s != self.nonstandard_kpi.to_s
    if (key1 || key2 || key3 || key4 || key5 || key6)
      order = self.order
      return order && (order.change_examinations_status(current_user) || order.update_order_columns)
    else
      return false
    end
  end

  def update_change_gp(change_gp)
    self.update_columns(change_gp: change_gp)
  end

  #订单修改货币单位后重新计算产品折扣
  def update_discount
    self.update_columns(:discount => recount)
  end

  def recount
    (cost * 100 / public_price.round(2)).round(2) rescue 0.0
  end


end
