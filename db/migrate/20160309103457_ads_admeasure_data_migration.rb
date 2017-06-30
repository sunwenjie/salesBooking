class AdsAdmeasureDataMigration < ActiveRecord::Migration
  def change
    advertisements = Advertisement.where("admeasure is not null")
    if advertisements.present?
      advertisements.each{|ad|
        admeasure_en = []
        admeasures = ad.admeasure
        admeasures[0..-2].each{|admeasure|
          city = City.find_by_name(admeasure[0])
          admeasure_en << [city.city_name,admeasure[1]]
        }
        admeasure_en << ["All",admeasures[-1][1]]
        ad.admeasure_en =  admeasure_en
        ad.update_columns({:admeasure_en=> admeasure_en})
        # ad.save(:validate=>false)
      }
    end
  end

end
