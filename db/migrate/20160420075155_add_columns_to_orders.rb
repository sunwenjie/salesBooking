class AddColumnsToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :last_update_user, :string
    add_column :orders, :last_update_time, :datetime
  end
end
