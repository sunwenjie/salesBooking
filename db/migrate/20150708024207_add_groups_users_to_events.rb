class AddGroupsUsersToEvents < ActiveRecord::Migration
  def change
    add_column :events, :groups, :string
    add_column :events, :users, :string
  end
end
