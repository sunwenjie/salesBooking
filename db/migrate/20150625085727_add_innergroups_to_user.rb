class AddInnergroupsToUser < ActiveRecord::Migration
  def change
    add_column :users, :innergroups, :string
  end
end
