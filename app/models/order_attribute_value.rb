class OrderAttributeValue < ActiveRecord::Base
  belongs_to :order,inverse_of: :order_attribute_values
  belongs_to :sync_attribute,inverse_of: :order_attribute_values
  #serialize :value

  def self.get_sap_orders(order_ids)
    if order_ids.present?
    self.find_by_sql("select value from order_attribute_values where order_id in (#{order_ids.join(",")}) and attribute_en_name = 'sap_order'")
    end
  end
end
