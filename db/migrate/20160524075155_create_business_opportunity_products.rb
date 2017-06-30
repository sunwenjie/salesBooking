class CreateBusinessOpportunityProducts < ActiveRecord::Migration
  def change
    create_table :business_opportunity_products do |t|
      t.integer :business_opportunity_id
      t.integer :product_id
      t.string :sale_mode
      t.decimal :budget,precision: 11, scale: 2

      t.timestamps
    end
  end
end
