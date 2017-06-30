class LocationCode < ActiveRecord::Base
  establish_connection :xmo_production

  class << self
    def cities_by_name(name)
      find_by_sql("select * from (select city_name,city_name_cn from xmo.location_codes where country_name = 'China' union all select replace(name,' ','') as city_name,name_cn as city_name_cn from xmo.province_codes) t where t.city_name in (#{name}) or t.city_name_cn in (#{name}) ")
    end

    def provinces
      find_by_sql("select name_cn,city_level,city_name,city_name_cn,criteria_id,province_id,area,area_cn from province_codes,location_codes where location_codes.province_id = province_codes.code_id and country_name='china' and city_name is not null")
    end

    def city_counts
      find_by_sql("select province_id,count(*) as num from location_codes where country_name in ('China','Taiwan','Hong Kong','Macau')  group by province_id")
    end

    def city_name_by_province(province_ids)
      where({"criteria_id" => province_ids}).where("city_name_cn is not null and city_name is not null")
    end

    #各省下城市个数
    def province_city_num
      city_counts.map { |x| [x["province_id"], x["num"]] }.to_h
    end
  end
end