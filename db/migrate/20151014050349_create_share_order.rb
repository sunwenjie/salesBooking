class CreateShareOrder < ActiveRecord::Migration
  def change
    create_table :share_orders do |t|
      t.integer :order_id
      t.integer :share_id
      t.timestamps
    end
  end
end
