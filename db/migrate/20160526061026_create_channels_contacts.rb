class CreateChannelsContacts < ActiveRecord::Migration
  def change
    create_table :channels_contacts do |t|
      t.integer :channel_id, limit: 11
      t.string :contact_person
      t.string :phone
      t.string :email
      t.string :position

      t.timestamps
    end
  end
end
