class AddGpEvaluateToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :gp_evaluate, :float
  end
end
