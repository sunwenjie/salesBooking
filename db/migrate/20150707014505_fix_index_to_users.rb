class FixIndexToUsers < ActiveRecord::Migration
  def change
    remove_index :users, :username if index_exists?(:users,:username)
    remove_index :users, :email if index_exists?(:users,:email)
    add_index :users,[:username,:email],unique: true if !index_exists?(:users,[:username,:email])
  end
end
