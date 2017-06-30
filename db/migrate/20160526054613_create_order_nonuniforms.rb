class CreateOrderNonuniforms < ActiveRecord::Migration
  def change
    create_table :order_nonuniforms do |t|
      t.date :start_date
      t.date :end_date
      t.decimal :nonuniform_budget,precision: 10, scale: 2
      t.integer :order_id

      t.timestamps
    end
  end
end
