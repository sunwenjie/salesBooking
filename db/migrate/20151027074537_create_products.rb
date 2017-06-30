class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :product_serial
      t.string :name
      t.string :sale_model
      t.boolean :is_accord_by_actual_amount
      t.integer :actual_accord_lowest_buy_amount
      t.string :product_type
      t.string :bu
      t.string :executive_team
      t.integer :single_buy_amount
      t.boolean :is_single_check_amount
      t.boolean :is_non_standard_check_amount
      t.string :approval_team
      t.boolean :is_support_click_monitor
      t.boolean :is_support_display_monitor
      t.string  :regional
      t.integer :public_price
      t.float   :general_discount
      t.float   :floor_discount
      t.float   :ctr_prediction
      t.string  :currency
      t.timestamps
    end
  end
end
