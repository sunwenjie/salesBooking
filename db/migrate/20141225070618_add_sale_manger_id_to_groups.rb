class AddSaleMangerIdToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :sales_manager_id, :integer
    add_index :groups,:sales_manager_id
  end
end
