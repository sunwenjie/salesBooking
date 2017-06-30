class AddCountryDataToOrders < ActiveRecord::Migration
  def change
  	Order.all.each do |order|
  		order.country = ["CHINA"]
  		order.save
  	end
  end
end
