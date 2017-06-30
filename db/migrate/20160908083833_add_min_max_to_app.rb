class AddMinMaxToApp < ActiveRecord::Migration
  def change
    add_column :approval_flows, :min, :decimal ,precision: 10, scale: 2
    add_column :approval_flows, :max, :decimal ,precision: 10, scale: 2
  end
end
