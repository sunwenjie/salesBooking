class AddGpCheckToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :gp_check, :boolean
  end
end
