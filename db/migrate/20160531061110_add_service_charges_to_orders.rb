class AddServiceChargesToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :service_charges, :decimal, precision: 10, scale: 2
    add_column :orders, :service_charges_scale,:decimal, precision: 6, scale: 2
  end
end
