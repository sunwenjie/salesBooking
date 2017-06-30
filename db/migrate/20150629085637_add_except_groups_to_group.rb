class AddExceptGroupsToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :except_groups, :string
  end
end
