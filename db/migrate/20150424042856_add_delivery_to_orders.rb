class AddDeliveryToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :delivery, :string
  end
end
