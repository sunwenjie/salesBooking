class AssignmentClientGroups < ActiveRecord::Migration
  def change
    create_table :client_groups,:id => false do |t|
      t.references :client
      t.references :group
    end
    add_index :client_groups, [:client_id]
    add_index :client_groups, [:group_id]
  end
end
