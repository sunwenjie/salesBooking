class AddIsDeleteToProducts < ActiveRecord::Migration
  def change
    add_column :products, :is_delete, :boolean ,default: false
  end
end
