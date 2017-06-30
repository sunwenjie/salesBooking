class AddChildrengroupsToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :childrengroups, :string
  end
end
