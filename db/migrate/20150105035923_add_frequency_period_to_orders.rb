class AddFrequencyPeriodToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :frequency_period, :string
    add_column :orders, :frequency_plan, :string
  end
end
