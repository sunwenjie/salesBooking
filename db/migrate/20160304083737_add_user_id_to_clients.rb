class AddUserIdToClients < ActiveRecord::Migration
  def change
    add_column :clients, :user_id, :integer
    execute "update clients inner join xmo.users on trim(clients.created_user) = trim(xmo.users.username) set clients.user_id = xmo.users.id where xmo.users.agency_id = 1"
  end
end
