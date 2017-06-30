class ProvinceCode < ActiveRecord::Base
 establish_connection "xmo_production".to_sym
  #全国省名称
  def self.province_name
   ProvinceCode.all.map(&:name_cn)- %w{北京 上海 天津 重庆 香港 澳门 台湾}
  end
end