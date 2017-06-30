class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.string :name, unique: true, null: false
      t.string :linkman_name
      t.string :linkman_tel
      t.string :email
      t.string :created_user
      t.string :state
      t.timestamps
    end
    
    add_index :clients,:name
    add_index :clients,:linkman_name
    add_index :clients,:linkman_tel
    add_index :clients,:created_user
  end
end
