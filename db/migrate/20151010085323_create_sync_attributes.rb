class CreateSyncAttributes < ActiveRecord::Migration
  def change
    create_table :sync_attributes do |t|
      t.string :en
      t.string :cn
      t.string :type
      t.string :system

      t.timestamps
    end
  end
end
