class LocationRegion < ActiveRecord::Base
  establish_connection :xmo_production

  def self.all_foreign_country
    find_by_sql("select continent_name1 ,continent_name1_en,country_id,country_name,continent_name_en from location_regions where continent_name='全球' and continent_name1_en is not null")
  end

  def self.foreign_country_by_id(country_ids)
    where({country_id: country_ids.split(',')})
  end

end