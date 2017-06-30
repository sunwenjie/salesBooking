class AddSubmitToPlannerOnOrders < ActiveRecord::Migration
  def change
    add_column :orders, :planner_check, :boolean
  end
end
