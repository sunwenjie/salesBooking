class CreateDefaultMarketCosts < ActiveRecord::Migration
  def change
    create_table :default_market_costs do |t|
      t.string :bu
      t.decimal :market_cost,precision: 10, scale: 2
      t.integer :order_by
      t.timestamps
    end
  end
end
