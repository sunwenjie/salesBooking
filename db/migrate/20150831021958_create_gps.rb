class CreateGps < ActiveRecord::Migration
  def change
    create_table :gps do |t|
      t.integer :order_id
      t.integer :advertisement_id
      t.integer :media_id
      t.float :pv_config
      t.float :gp
      t.timestamps
    end
  end
end
