class Gp < Base
  belongs_to :advertisement,inverse_of: :gps, touch:true
  belongs_to :order,inverse_of: :gps

  #attr_accessor :weight_live

  #获取媒体分配的GP值
  def get_gp
    cost_type = self.advertisement.cost_type.downcase
    send("media_#{cost_type}_gp")
  end

  #获取媒体分配的GP%率
  def get_gp_rake
    return 0  if ( !self.pv_config_scale || self.pv_config_scale == 0 )
    if self.city == "-"
       get_gp.to_f / ( self.order.budget.to_f * ( self.advertisement.budget_ratio.to_f / 100.00 ) * ( self.pv_config_scale / 100 ) )
    else
      admeasure = self.advertisement.get_admeasure_array(self.city)
       get_gp.to_f / ( self.order.budget.to_f * ( self.advertisement.budget_ratio.to_f / 100.00 ) * ( self.pv_config_scale / 100 ) * ( admeasure[1].to_f / self.advertisement.budget_ratio("super")) )
    end
  end

  def media_cpm_gp
    if self.pv_config && self.pv_config != 0 && self.average_cost_cpm
      ( (self.advertisement.cost.to_f - self.average_cost_cpm) * self.pv_config )
    else
      0
    end
  end

  def media_cpc_gp
    if self.pv_config && self.pv_config != 0 && self.advertisement.get_average_cost(self.city)
      (self.advertisement.cost.to_f - self.advertisement.get_average_cost(self.city) ) * self.pv_config * 1000
    else
      0
    end
  end

  #查询已分配gp信息
  def self.get_gp_list(order_id)
    find_by_sql("select id,order_id,city,advertisement_id,media,media_type,media_form,ad_original_size,ad_original_size,ad_expand_size,ctr,ifnull(pv_config,0) as pv_config,ifnull(round(pv_config_scale,2),0) as  pv_config_scale,gp,average_cost_cpm from gps where save_flag = 1 and pv_config_scale >0  and order_id = #{order_id} order by advertisement_id asc")
  end
  
  #获取地域/产品的总gp%
  def get_total_rake(check_city = nil)
      if self.city == "-" || check_city == "-"
         self.advertisement.get_advertisement_gps_rake
      else
         self.advertisement.get_admeasure_gps_rake(self.city)
      end
  end

  #获取地域/产品的cpm/cpc总价
  def get_total_price(check_city = nil)
      if self.city == "-" || check_city == "-"
         self.advertisement.get_advertisement_gps_total_price
      else
         self.advertisement.get_admeasure_gps_total_price(self.city)
      end
  end

end