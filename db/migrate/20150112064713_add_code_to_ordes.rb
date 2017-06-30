class AddCodeToOrdes < ActiveRecord::Migration
  def change
    add_column :orders, :third_monitor_code, :text
    add_column :orders, :screenshot, :text
  end
end
