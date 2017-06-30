class AddManagersToUsers < ActiveRecord::Migration
  def change
    add_column :users, :managers, :string
  end
end
