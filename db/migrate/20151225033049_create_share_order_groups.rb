class CreateShareOrderGroups < ActiveRecord::Migration
  def change
    create_table :share_order_groups do |t|
      t.integer :order_id
      t.integer :share_id
      t.timestamps
    end
  end
end
