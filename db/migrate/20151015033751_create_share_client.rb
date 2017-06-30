class CreateShareClient < ActiveRecord::Migration
  def change
    create_table :share_clients do |t|
      t.integer :client_id
      t.integer :share_id
      t.timestamps
    end
  end
end
