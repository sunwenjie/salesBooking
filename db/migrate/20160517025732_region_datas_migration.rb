class RegionDatasMigration < ActiveRecord::Migration
  def change
    Order.migration_geo_data
  end
end
