class AddExceptUsersToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :except_users, :string
  end
end
