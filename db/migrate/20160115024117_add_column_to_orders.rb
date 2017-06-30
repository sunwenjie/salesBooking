class AddColumnToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :gp_commit_user, :string
    add_column :orders, :schedule_commit_user, :string
  end
end
