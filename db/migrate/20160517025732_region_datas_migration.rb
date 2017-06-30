class RegionDatasMigration < ActiveRecord::Migration
  def change
    #老数据地域迁移，迁移之前请先备份orders表。
      old_countries_key = {"US" =>"1840000000", "UK" => "1826000000", "AU" => "1036000000", "NZ" => "1554000000", "MY" => "1458000000", "SG" => "1702000000", "HK" => "2344" , "TW" => "2158", "MA"=> "2446"}
      old_name_key = {"BJ" => "1003334", "CQ" => "1003591", "SH" => "1003401", "TJ" => "1003338"}
      municipality_ids_key = {"20163" => "1003334","20184" => "1003591", "20171" => "1003401","20164" => "1003338"}
      old_municipality_ids = ["20163","20184","20171","20164"]
      new_municipality_ids = ["1003591","1003401","1003334","1003338"]
      municipality_name_key = ["BJ","CQ","SH","TJ"]
      first_tier_city = ["BJ", "TJ", "SH", "GZ31" ,"SZ14"]
      sql_find_all_provinces = "select province_id, GROUP_CONCAT(criteria_id) city_id from xmo.location_codes where province_id not in (1003591,1003401,1003334,1003338) and province_id is not null group by province_id "
      sql_find_all_cities_by_provinces = "select province_id, GROUP_CONCAT(criteria_id) city_id from cities where province_id in (?) and province_id is not null group by province_id"
      sql_find_cities_by_provinces = "select province_id, GROUP_CONCAT(criteria_id) city_id from cities where province_id in (?) and name_key in (?) and province_id is not null group by province_id"
      sql_find_all_cities_by_citylevel = "select province_id, GROUP_CONCAT(criteria_id) city_id from cities where province_id not in (1003591,1003401,1003334,1003338) and city_level in (1,2,3,4) and province_id is not null group by province_id"
      sql_find_cities_by_citylevel = "select province_id, GROUP_CONCAT(criteria_id) city_id from cities where province_id not in (1003591,1003401,1003334,1003338) and city_level in (?) and province_id is not null group by province_id"
      sql_find_by_name_key = "select province_id, GROUP_CONCAT(criteria_id) city_id from cities where province_id not in (1003591,1003401,1003334,1003338) and city_level in (?) and name_key in (?) and province_id is not null group by province_id"
      sql_find_all_cities_exclude_hk = "select province_id, GROUP_CONCAT(criteria_id) city_id from xmo.location_codes where province_id not in (1003591,1003401,1003334,1003338,2344,2446,2158) and province_id is not null group by province_id "
      sql_find_cities_exclude_hk = "select province_id, GROUP_CONCAT(criteria_id) city_id from cities where province_id not in (1003591,1003401,1003334,1003338,2344,2446,2158) and name_key in (?) and province_id is not null group by province_id "
      sql_find_countries_by_key = "select country_id from xmo.location_regions where continent_name_en in (?) and continent_name = '全球'"
      #orders = Order.where("id in (?)",[1163,1164,1165,1167,1168,1169,1170,1171,1172,1173,1174,1175,1176,1187,1188,1189])
      orders = Order.all
      orders.each do |order|
        provinces = []
        new_regions = []
        db_country = order.country.present? ? order.country : ["china"]
        name_en_array = db_country - ["all_countrys"]
        special_countries = db_country - ["special_country"]
        if !order.new_regions.present?
          case order.regional
            when "US_UK_AU_NZ_MY"
              country_ids = get_country_province_id(name_en_array, old_countries_key)
              new_regions = [{"country" => "foregin", "country_id" => country_ids.join(",")}]
            when "HK_TW_MA_SG"
              china_pro = name_en_array - ["SG"]
              provinces_ids = get_country_province_id(china_pro, old_countries_key)
              provinces = map_proid(provinces_ids)
              if !name_en_array.include?("SG")
                new_regions = [{"country" => "china", "province" => provinces, "isChinaAll" => false}]
              else
                new_regions = china_pro.length < 1 ? [{"country" => "foregin", "country_id" => "1702000000"}] : [{"country" => "china", "province" => provinces, "isChinaAll" => false}, {"country" => "foregin", "country_id" => "1702000000"}]
              end
            when "OTHER_COUNTRY"
              new_regions = nil
            when "SPECIAL_COUNTRY"
              if special_countries.join(",") == "all_countrys"
                #new_regions = order.new_regions
                provinces = find_all_china_regions(new_municipality_ids,sql_find_all_provinces)
                new_regions = [{"country" => "china", "province" => provinces.flatten, "city_level" => "1,2,3,4", "isChinaAll" => true}]
                country_ids = get_country_province_id(["US","UK","AU","NZ","MY","SG"], old_countries_key)
                foreign_countries = TRY_OPTIONS.map{|value| value[1]} - ["US","UK","AU","NZ","MY","SG","HK","TW","MA"]
                part_country_ids =  Order.find_by_sql([sql_find_countries_by_key,foreign_countries])
                country_ids = country_ids + part_country_ids.map(&:country_id)
                new_regions << {"country" => "foregin", "country_id" => country_ids.join(",")}
              else
                if special_countries.include?("china") || special_countries.include?("CHINA")
                  provinces = find_all_china_regions(new_municipality_ids,sql_find_all_provinces)
                  new_regions = [{"country" => "china", "province" => provinces.flatten, "city_level" => "1,2,3,4", "isChinaAll" => true}]
                elsif (special_countries - ["china","CHINA"]).length > 0
                  hk_tw_ma = special_countries & ["HK","TW","MA"]
                  exclude_hk_tw_ma = special_countries - ["HK","TW","MA"]
                  special_results = special_countries & ["US","UK","AU","NZ","MY","SG"]
                  custom_results = special_countries - ["US","UK","AU","NZ","MY","SG","HK","TW","MA"]
                  if hk_tw_ma.length  > 0 && exclude_hk_tw_ma.length < 0
                    provinces_ids = get_country_province_id(hk_tw_ma, old_countries_key)
                    provinces = map_proid(provinces_ids)
                    new_regions << [{"country" => "china", "province" => provinces, "isChinaAll" => false}]
                  elsif hk_tw_ma.length > 0 && exclude_hk_tw_ma.length > 0
                    provinces_ids = get_country_province_id(hk_tw_ma, old_countries_key)
                    provinces = map_proid(provinces_ids)
                    if special_results.length > 0
                      country_ids = special_results.present? ? get_country_province_id(special_results, old_countries_key) : []
                    end
                    if custom_results.length > 0
                      part_country_ids = custom_results.present? ?  Order.find_by_sql([sql_find_countries_by_key,custom_results]) : []
                    end
                    part_country_ids = part_country_ids.present? ? part_country_ids.map(&:country_id) : []
                    country_ids = (country_ids.present? ? country_ids : [])  + part_country_ids
                    new_regions << {"country" => "china", "province" => provinces, "isChinaAll" => false}
                    new_regions << {"country" => "foregin", "country_id" => country_ids.join(",")}
                  end
                end
              end
            else
              old_cities = order.city.present? && order.city.reject(&:empty?)
              old_deliveries = order.delivery
              if old_deliveries.present?
                delivery_provinces = old_deliveries["delivery_province"].reject(&:empty?)
                delivery_city_level = old_deliveries["delivery_city_level"].reject(&:empty?)
                provinces = []

                if old_deliveries["delivery_type"] == "1"
                  if delivery_provinces.join(",") == "all_provinces" || !delivery_provinces.present?
                    provinces = find_all_china_regions(new_municipality_ids,sql_find_all_provinces)
                    new_regions = [{"country" => "china", "province" => provinces.flatten, "city_level" => "1,2,3,4", "isChinaAll" => true}]
                  else
                    (included_old_municipality_ids,exclude_old_municipality_ids) = get_municipality_arr(delivery_provinces,old_municipality_ids)
                    if old_cities.present? && old_cities.join(",") == "all_cities"
                      if included_old_municipality_ids.present?
                        get_new_municipality_ids = get_country_province_id(included_old_municipality_ids, municipality_ids_key)
                        provinces << map_proid(get_new_municipality_ids)
                      end
                      #provinces = find_all_china_regions(get_new_municipality_ids,sql_find_all_cities_by_provinces,exclude_old_municipality_ids)
                      pro_ids = Order.find_by_sql([sql_find_all_cities_by_provinces, exclude_old_municipality_ids]) if exclude_old_municipality_ids.present?
                      provinces << map_proid_cityid(pro_ids)
                    elsif !old_cities.present?
                      pro_ids = Order.find_by_sql([sql_find_all_cities_by_provinces, exclude_old_municipality_ids]) if exclude_old_municipality_ids.present?
                      provinces << map_proid_cityid(pro_ids)
                    else
                      (include_municipality_name_key,exclude_municipality_name_key) = get_municipality_arr(old_cities,municipality_name_key)
                      get_new_municipality_ids = get_country_province_id(include_municipality_name_key, old_name_key)
                      provinces << map_proid(get_new_municipality_ids)
                      pro_ids = Order.find_by_sql([sql_find_cities_by_provinces,exclude_old_municipality_ids,exclude_municipality_name_key])
                      provinces << map_proid_cityid(pro_ids)
                    end
                    new_regions = [{"country" => "china", "province" => provinces.flatten, "isChinaAll" => false}]
                  end
                elsif old_deliveries["delivery_type"] == "2"
                  if delivery_city_level.join(",") == "all_city_level"
                    provinces = find_all_china_regions(new_municipality_ids,sql_find_all_cities_by_citylevel)
                    new_regions = [{"country" => "china", "province" => provinces.flatten, "city_level" => "1,2,3,4", "isChinaAll" => false}]
                  else
                    if old_cities.present? && old_cities.join(",") == "all_cities"
                      if delivery_city_level.present?
                        provinces << map_proid(new_municipality_ids - ["1003591"]) if delivery_city_level.include?("1")
                        provinces << map_proid(["1003591"]) if delivery_city_level.include?("2")
                        pro_ids = Order.find_by_sql([sql_find_cities_by_citylevel,delivery_city_level])
                        provinces << map_proid_cityid(pro_ids)
                        new_regions = [{"country" => "china", "province" => provinces.flatten, "city_level" => delivery_city_level.join(","), "isChinaAll" => false}]
                      else
                        provinces = find_all_china_regions(new_municipality_ids,sql_find_all_provinces)
                        new_regions = [{"country" => "china", "province" => provinces.flatten, "city_level" => "1,2,3,4", "isChinaAll" => true}]
                      end
                    elsif !old_cities.present? && delivery_city_level.present?
                      provinces << map_proid(new_municipality_ids - ["1003591"]) if delivery_city_level.include?("1")
                      provinces << map_proid(["1003591"]) if delivery_city_level.include?("2")
                      pro_ids = Order.find_by_sql([sql_find_cities_by_citylevel,delivery_city_level])
                      provinces << map_proid_cityid(pro_ids)
                      new_regions = [{"country" => "china", "province" => provinces.flatten, "city_level" => delivery_city_level.join(","), "isChinaAll" => false}]
                    else
                      select_name_key = old_cities.present? ? old_cities : []
                      (include_municipality_name_key,exclude_municipality_name_key) = get_municipality_arr(old_cities,municipality_name_key)
                      get_new_municipality_ids = get_country_province_id(include_municipality_name_key, old_name_key)
                      provinces << map_proid(get_new_municipality_ids)
                      pro_ids = Order.find_by_sql([sql_find_by_name_key,delivery_city_level,exclude_municipality_name_key])
                      provinces << map_proid_cityid(pro_ids)
                      regions = {"country" => "china", "province" => provinces.flatten, "isChinaAll" => false}
                      regions = (select_name_key & first_tier_city).length == 5 ? regions.merge("city_level" => "1") : regions
                      new_regions = [regions]
                    end
                  end
                elsif old_deliveries["delivery_type"] == "3"
                  if old_cities.present? && old_cities.join(",") == "all_cities"
                    provinces = find_all_china_regions(new_municipality_ids,sql_find_all_cities_exclude_hk)
                    new_regions = [{"country" => "china", "province" => provinces.flatten, "city_level" => "1,2,3,4", "isChinaAll" => true}]
                  elsif !old_cities.present?
                    provinces = find_all_china_regions(new_municipality_ids,sql_find_all_cities_exclude_hk)
                    new_regions = [{"country" => "china", "province" => provinces.flatten, "city_level" => "1,2,3,4", "isChinaAll" => true}]
                  else
                    (include_municipality_name_key,exclude_municipality_name_key) = get_municipality_arr(old_cities,municipality_name_key)
                    get_new_municipality_ids = get_country_province_id(include_municipality_name_key, old_name_key)
                    provinces << map_proid(get_new_municipality_ids)
                    pro_ids = Order.find_by_sql([sql_find_cities_exclude_hk,exclude_municipality_name_key]) if exclude_municipality_name_key.present?
                    provinces << map_proid_cityid(pro_ids)
                    new_regions = [{"country" => "china", "province" => provinces.flatten, "isChinaAll" => false}]
                  end
                else
                  provinces = find_all_china_regions(new_municipality_ids,sql_find_all_provinces)
                  new_regions = [{"country" => "china", "province" => provinces.flatten, "city_level" => "1,2,3,4", "isChinaAll" => true}]
                end
              else
                if old_cities.present? && (old_cities.join(",") == "all_cities" || old_cities.join(",") == "otherall")
                  provinces = find_all_china_regions(new_municipality_ids,sql_find_all_provinces)
                  new_regions = [{"country" => "china", "province" => provinces.flatten, "city_level" => "1,2,3,4", "isChinaAll" => true}]
                elsif !old_cities.present?
                  new_regions = nil
                else
                  (include_municipality_name_key,exclude_municipality_name_key) = get_municipality_arr(old_cities,municipality_name_key)
                  get_new_municipality_ids = get_country_province_id(include_municipality_name_key, old_name_key)
                  provinces << map_proid(get_new_municipality_ids)
                  pro_ids = Order.find_by_sql([sql_find_cities_exclude_hk,exclude_municipality_name_key]) if exclude_municipality_name_key.present?
                  provinces << map_proid_cityid(pro_ids)
                  new_regions = [{"country" => "china", "province" => provinces.flatten, "isChinaAll" => false}]
                end
              end
          end
          order.update_columns({:new_regions => new_regions.present? ? ActiveSupport::JSON.encode(new_regions) : nil })
          #p order.errors.messages
      end
      end

      def self.get_country_province_id(name_en_array, key)
        return [] if !name_en_array.present?
        country_ids = name_en_array.inject([]) do |f,item|
          f << key[item]
        end
        return country_ids
      end

      def self.map_proid(arr)
        return [] if !arr.present?
        arr.map do |id|
          ["province_id" => id.to_s, "city_id" => id.to_s]
        end.flatten
      end

      def self.map_proid_cityid(arr)
        return [] if !arr.present?
        arr.map do |id|
          ["province_id" => id.province_id.to_s, "city_id" => id.city_id.to_s]
        end.flatten
      end

      def self.get_municipality_arr(data_arr = [],municipality_array = [])
        return [] if data_arr.blank? || municipality_array.blank?
        return data_arr & municipality_array, data_arr - municipality_array
      end

      def self.find_all_china_regions(arr_ids,sql,sql_params1 = nil,sql_params2 = nil)
        #sql =~ /\?/
        provinces = []
        provinces << map_proid(arr_ids)
        sql_arry = [sql]
        sql_arry << sql_params1 if sql_params1.present?
        sql_arry << sql_params2 if sql_params2.present?
        pro_ids = Order.find_by_sql(sql_arry)
        provinces << map_proid_cityid(pro_ids)
        return provinces
      end
  end
end
