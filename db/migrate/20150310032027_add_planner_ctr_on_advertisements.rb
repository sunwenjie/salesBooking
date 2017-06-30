class AddPlannerCtrOnAdvertisements < ActiveRecord::Migration
  def change
    add_column :advertisements, :planner_ctr, :float
  end
end
