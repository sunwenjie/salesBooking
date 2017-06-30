class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.integer :approval_flow_id
      t.integer :create_user
      t.integer :approval_user
      t.integer :node_id
      t.string :model

      t.timestamps
    end
  end
end
