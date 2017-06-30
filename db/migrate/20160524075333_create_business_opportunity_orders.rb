class CreateBusinessOpportunityOrders < ActiveRecord::Migration
  def change
    create_table :business_opportunity_orders do |t|
      t.integer :business_opportunity_id
      t.integer :order_id

      t.timestamps
    end
  end
end
