class AddSyncFlagToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :sync_flag, :integer
    add_column :orders, :sync_time, :datetime
  end
end
