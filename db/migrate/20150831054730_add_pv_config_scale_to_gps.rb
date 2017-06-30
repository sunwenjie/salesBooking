class AddPvConfigScaleToGps < ActiveRecord::Migration
  def change
    add_column :gps, :pv_config_scale, :float
  end
end
