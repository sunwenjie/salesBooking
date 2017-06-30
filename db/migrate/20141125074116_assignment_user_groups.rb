class AssignmentUserGroups < ActiveRecord::Migration
  def change
    create_table :user_groups,:id => false do |t|
      t.references :user
      t.references :group
    end
    add_index :user_groups, [:user_id]
    add_index :user_groups, [:group_id]
  end
end
