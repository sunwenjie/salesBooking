class AddGpScheduleTimeToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :gp_commit_time, :datetime
    add_column :orders, :schedule_commit_time, :datetime
  end
end
