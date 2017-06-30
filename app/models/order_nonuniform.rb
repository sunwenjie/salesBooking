class OrderNonuniform < ActiveRecord::Base
  belongs_to :order,inverse_of: :order_nonuniforms

  def self.insert_order_nonuniforms(order_id,all_nonuniforms_date_range,all_nonuniform_budget)
    all_nonuniforms_date_range.each do |d|
      order_nonuniform = OrderNonuniform.new
      order_nonuniform.order_id = order_id
      order_nonuniform.start_date = d[1].split("~")[0]
      order_nonuniform.end_date = d[1].split("~")[1]
      order_nonuniform.nonuniform_budget = all_nonuniform_budget[d[0].gsub("_date_range","_budget")].present? ? all_nonuniform_budget[d[0].gsub("_date_range","_budget")].gsub(',','') : nil
      order_nonuniform.save
    end
  end

end
