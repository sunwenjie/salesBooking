class CreateChannelRebates < ActiveRecord::Migration
  def change
    create_table :channel_rebates do |t|
      t.date :start_date
      t.date :end_date
      t.decimal :rebate,precision: 6, scale: 3
      t.integer :channel_id
      t.timestamps
    end
  end
end
