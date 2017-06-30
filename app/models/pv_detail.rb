class PvDetail < ActiveRecord::Base
  establish_connection "xmo_production".to_sym
  belongs_to :placement
  has_many :pv_deal

  def need_pv
    self.booked_pv + self.saled_pv + self.used_pv
  end

  def store_pv
    store_pv_data = (self.all_pv * 0.8 - need_pv).to_i
    store_pv_data < 0 ? 0 : store_pv_data
  end

  def process_pv(pv,type)
    case type
    when 'booking'
      self.booked_pv += pv
    when 'approve_yes'
      self.booked_pv -= pv
      self.saled_pv += pv
    when 'approve_no'
      self.booked_pv -= pv
    when 'campagin'
      self.saled_pv -= pv
    when 'cancle'
      self.booked_pv -= pv
    end
  end
end