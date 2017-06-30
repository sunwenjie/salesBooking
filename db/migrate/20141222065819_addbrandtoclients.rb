class Addbrandtoclients < ActiveRecord::Migration
  def change
    add_column :clients, :brand, :string
    add_column :clients, :linkman_position, :string
    add_column :clients, :address, :string
  end
end
