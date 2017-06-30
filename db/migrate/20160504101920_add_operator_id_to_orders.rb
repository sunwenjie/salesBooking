class AddOperatorIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :operator_id, :integer
    execute "update orders inner join xmo.users on trim(orders.operator) = trim(xmo.users.username) set orders.operator_id = xmo.users.id where xmo.users.agency_id = 1"
  end
end
