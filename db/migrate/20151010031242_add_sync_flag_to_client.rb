class AddSyncFlagToClient < ActiveRecord::Migration
  def change
    add_column :clients, :sync_flag, :integer
    add_column :clients, :sync_time, :datetime
  end
end
