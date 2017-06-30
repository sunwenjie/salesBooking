class AddSomeColumnsToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :is_standard, :boolean
    add_column :orders, :have_admeasure_map, :boolean
    add_column :orders, :is_jast_for_gp, :boolean
    add_column :orders, :is_gp_finish, :boolean
  end
end
