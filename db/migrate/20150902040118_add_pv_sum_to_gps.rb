class AddPvSumToGps < ActiveRecord::Migration
  def change
    add_column :gps, :pv_sum, :integer
  end
end
