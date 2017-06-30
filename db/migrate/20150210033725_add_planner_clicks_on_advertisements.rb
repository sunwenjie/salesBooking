class AddPlannerClicksOnAdvertisements < ActiveRecord::Migration
  def change
    add_column :advertisements, :planner_clicks, :integer
  end
end
