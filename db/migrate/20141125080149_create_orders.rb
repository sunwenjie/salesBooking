class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :code, unique: true, null: false
      t.string :license
      t.date :start_date
      t.date :ending_date
      t.string :regional
      t.string :ad_platform
      t.string :ad_type
      t.decimal :budget, precision: 10, scale: 2
      t.string :budget_currency
      t.string :linkman
      t.string :linkman_tel
      t.string :country
      t.string :city
      t.string :cost_type
      t.decimal :cost, precision: 6, scale: 2
      t.string :cost_currency
      t.float :discount
      t.text :price_presentation
      t.text :convert_goal
      t.text :extra_website #for MEDIA_BUYING
      t.text :interest_crowd #for ANDIENCE_BUYING
      t.text :blacklist_website
      t.text :description
      t.string :operator
      t.integer :position, :default => 0
      t.datetime :deleted_at
      t.string :state
      t.timestamps
    end
    add_index :orders,:code
    add_index :orders,:license
    add_reference :orders, :industry, index: true
    add_reference :orders, :client, index: true
    add_reference :orders, :user, index: true
  end
end
