class AddSelectUsersToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :select_users, :string
  end
end
