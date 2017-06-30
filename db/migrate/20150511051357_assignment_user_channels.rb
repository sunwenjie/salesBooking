class AssignmentUserChannels < ActiveRecord::Migration
  def change
    create_table :user_channels,:id => false do |t|
      t.references :user
      t.references :channel
    end
    add_index :user_channels, [:user_id]
    add_index :user_channels, [:channel_id]
  end
end
