class AddMarketCostToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :market_cost, :decimal ,precision: 6, scale: 2
    add_column :orders, :net_gp, :decimal, precision: 6, scale: 2
  end
end
