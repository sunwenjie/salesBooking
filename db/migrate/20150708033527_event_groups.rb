class EventGroups < ActiveRecord::Migration
  def change
    create_table :event_groups,:id => false do |t|
      t.references :event
      t.references :group
    end
    add_index :event_groups, [:event_id]
    add_index :event_groups, [:group_id]
  end
end
