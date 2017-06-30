class CreateShareAms < ActiveRecord::Migration
  def change
    create_table :share_ams do |t|
      t.integer :user_id
      t.integer :operation_id

      t.timestamps
    end
  end
end
