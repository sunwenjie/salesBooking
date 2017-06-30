class EventUsers < ActiveRecord::Migration
  def change
    create_table :event_users,:id => false do |t|
      t.references :event
      t.references :user
    end
    add_index :event_users, [:event_id]
    add_index :event_users, [:user_id]
  end
end
