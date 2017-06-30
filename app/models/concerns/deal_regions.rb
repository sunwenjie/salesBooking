module Concerns
  module DealRegions
    #城市匹配
    def map_city(language = nil)
      if self.id > 1537
        ad_region_name(language)
      else
        order_city_name
      end
    end

    def map_country(language = nil)
      language = language.present? ? language : I18n.locale.to_s
      en_language = language == 'en'
      country = []
      new_regions = self.new_regions
      if new_regions.present?
        new_regions = JSON.parse new_regions
        new_regions.each { |region|
          country_type = region['country']
          china = country_type == 'china'
          foreign = country_type == 'foregin'
          if china_region_all?
            country << (en_language ? 'All China' : '全中国')  if china
          else
            country << (en_language ? 'China' : '中国') if china
          end
          country += LocationRegion.foreign_country_by_id(region['country_id']).map { |foregin_country| en_language ? foregin_country.continent_name_en : foregin_country.country_name } if foreign
        }
      end
      country.join(' ').strip
    end

    #地域是否选择全部
    def china_region_all?
      china_all = false
      new_regions = self.new_regions
      if new_regions.present?
        regions = JSON.parse new_regions
        china_all = regions[0]['isChinaAll'] if regions[0]['country'] == 'china'
      end
      return china_all
    end

    #订单城市解析
    def order_city_name(translate = nil)
      language = I18n.locale.to_s
      cityname = []
      order_regions = self.new_regions
      if order_regions.present?
        new_regions = []
        regions = JSON.parse order_regions
        regions.each do |r|
          if r['province']
            r['province'].each do |p|
              p_city = p['city_id']
              new_regions << p_city.split(',') if p_city.present?
            end
          end
        end
        new_regions.flatten
        cityname = region_name_by_province(new_regions,language,translate).sort
      end
      return cityname.join(',')
    end

    #产品地域预算 地域解析（支持按省或地市预算）
    def ad_region_name(language = nil)
      language = language.present? ? language : I18n.locale.to_s
      cityname = []
      regions = regions_to_json(self.new_regions)
      if regions.present?
        new_regions = []
        regions.each do |r|
          if r['province']
            r['province'].each do |p|
              province_id = p['province_id']
              city_id = p['city_id'].split(',')
              if LocationCode.province_city_num[province_id] != city_id.size
                new_regions << city_id if city_id.present?
              else
                new_regions << province_id
              end
            end
          end
        end
        new_regions.flatten
        cityname = region_name_by_province(new_regions,language).sort
      end
      return cityname.join(",")
    end

    #订单地域组件数据封装
    def locations_info
      provices = LocationCode.provinces
      province_codes = ProvinceCode.all
      foreigns = LocationRegion.all_foreign_country
      foreign = []
      china = []

      if !self.new_record?
        new_regions = get_new_regions rescue []
      end
      foreigns.each do |fo|
        f = {foreign_name_cn: fo.country_name, foreign_name: fo.continent_name_en, foreign_id: fo.country_id.to_s, continent_name_cn: fo.continent_name1, continent_name: fo.continent_name1_en}
        foreign << f
      end
      province_codes.each do |pro|
        cities = []
        provices.each do |i|
          if i.province_id == pro.code_id
            city_level = i.city_level.blank? ? '' : i.city_level.to_s.gsub('0', '')
            city = {city_name_cn: i.city_name_cn, city_id: i.criteria_id.to_s, city_name: i.city_name, city_level: city_level }
            cities << city
          end
        end
        if ['20171', '20163', '20164', '20184'].include? pro.code_id.to_s
          pro.code_id = cities[0][:city_id]
          cities = []
        end
        province = {provice_id: pro.code_id, provice_name_cn: pro.name_cn, provice_name: pro.name, area: pro.area, area_cn: pro.area_cn, cities: cities}
        china << province
      end
      return china, foreign, new_regions, provices.count+3
    end

    private
    def region_name_by_province(province_ids,language,translate = nil)
      cn_language = language == 'zh-cn'
      region1 = LocationCode.city_name_by_province(province_ids).collect { |city| (translate || cn_language) ? city.city_name_cn : city.city_name }
      region2 = ProvinceCode.where({code_id: province_ids}).collect { |province| (translate || cn_language) ? province.name_cn : province.name }
      region2 + region1.sort
    end

    def diff_regions?(origin_order)
      origin_order_regions = regions_to_json(origin_order.new_regions,true)
      new_regions = regions_to_json(self.new_regions,true)
      origin_order_foreign = []
      new_regions_foreign = []
      if new_regions && origin_order_regions
        if new_regions[0]['country'] == 'china' && origin_order_regions[0]['country'] == new_regions[0]['country']
          origin_order_province = []
          new_regions_province = []
          #china
          origin_order_province = origin_order_regions[0]['province'] if origin_order_regions[0]['province'].present?
          new_regions_province = new_regions[0]['province'] if new_regions[0]['province'].present?
          origin_order_province = origin_order_province.sort { |x, y| y['province_id'] <=> x['province_id'] }
          new_regions_province = new_regions[0]['province'].sort { |x, y| y['province_id'] <=> x['province_id'] } if new_regions[0]['province'].present?

          #foreign
          origin_order_foreign = origin_order_regions[1]['country_id'].split(',').sort { |x, y| x <=> y } if origin_order_regions[1].present?
          new_regions_foreign = new_regions[1]['country_id'].split(",").sort { |x, y| x <=> y } if new_regions[1].present?
          (origin_order_province != new_regions_province) || (origin_order_foreign != new_regions_foreign)
        elsif new_regions[0]['country'] == 'foregin' && origin_order_regions[0]['country'] == new_regions[0]['country']
          origin_order_foreign = origin_order_regions[0]['country_id'].split(',').sort { |x, y| x <=> y }
          new_regions_foreign = new_regions[0]['country_id'].split(',').sort { |x, y| x <=> y }
          origin_order_foreign != new_regions_foreign
        end
      elsif (new_regions.nil? && origin_order_regions.present?) || (origin_order_regions.nil? && new_regions.present?)
        true
      else
        false
      end
    end
    #解析当前订单地域数据
    def get_new_regions
      new_regions = []
      regions = JSON.parse self.new_regions
      regions.each do |r|
        if r['country_id']
          new_regions << r['country_id'].split(',')
        end
        if r['province']
          r['province'].each do |p|
            if p['city_id'].blank?
              new_regions << MAP_CITIES_ID[p['province_id']]
            else
              new_regions << p['city_id'].split(',')
            end
          end
        end
      end
      new_regions.flatten
    end

    def regions_to_json(regions,delete_city_level = nil)
      if regions.present?
        json_regions = JSON.parse regions
        json_regions[0].delete('city_level') if delete_city_level && json_regions[0]['city_level'].present?
        return json_regions
      end
    end
  end
end