class AddIsGpCommitToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :is_gp_commit, :boolean
  end
end
