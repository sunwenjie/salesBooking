class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name
      t.string :notify_method
      t.string :event_type

      t.timestamps
    end
  end
end
