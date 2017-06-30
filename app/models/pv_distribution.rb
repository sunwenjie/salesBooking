require 'csv'
class PvDistribution < ActiveRecord::Base
	establish_connection 'xmo_production'
  
	def self.import(file_path)
      CSV.foreach(file_path) do |row|
        if row.size > 0
          region = LocationRegion.find_by_city_id(row[0])
          city_id = row[0]
          row[0] = region.nil? ? nil : region.city_name
          PvDistribution.create(city_id: city_id, city_name: row[0], distribution_rate: row[1])
        end
      end
    end
end
