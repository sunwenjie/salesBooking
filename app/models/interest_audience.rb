require 'httparty'
require 'open-uri'
class InterestAudience < ActiveRecord::Base
  
  establish_connection "xmo_production"
  self.table_name = "bshare_audiences"
  # serialize :campaigns
  # serialize :ad_groups
  # serialize :keywords
  serialize :genders
  serialize :age_group
  # serialize :income_group
  serialize :city_group
  serialize :result_detail, Hash
  
  validates_uniqueness_of :name, :scope => :client_id, :case_sensitive => false
  INTEREST_MAP = {"1194"=>[], "1195"=>[], "1204"=>[], "1197"=>[], "1198"=>[], "1199"=>[],
    "1200"=>[], "1201"=>[], "1202"=>[], "1203"=>[], "1205"=>[], "1206"=>[], "1207"=>[], "1208"=>[],
    "1210"=>[], "1212"=>[], "1211"=>[], "1214"=>[], "1215"=>[], "1216"=>[],
    "1217"=>["1218", "1219", "1220", "1221", "1222", "1223", "1224", "1225", "1226", "1227"],
    "1228"=>["1229", "1230", "1231", "1232"],"1233"=>[],"1234"=>["1235", "1236", "1237", "1238", "1239", "1240", "1241", "1242", "1243", "1244", "1245", "1246"],
    "1247"=>["1248", "1249", "1250"],"1251"=>["1252", "1253", "1254", "1255", "1256", "1257", "1258"],"1259"=>[], "1260"=>[],
    "1261"=>[], "1262"=>[],"1263"=>["1264", "1265", "1266"],"1267"=>["1268", "1269", "1270", "1271"],
    "1272"=>["1273", "1274", "1275", "1276", "1277", "1278", "1279", "1280", "1281"],
    "1282"=>["1283", "1284", "1285"]}
  QUERY_URL = "http://xmo.bznx.net/service/api/custom_groups/query"
  
  INTEREST_CLIENT_ID = 922
  
  def self.interests(sub_ids = nil)
    if sub_ids.present?
      interest_ids = InterestAudience.interests_from_sub(sub_ids)
      InterestAudience.where("audience_id in (?) and client_id = ?", interest_ids, INTEREST_CLIENT_ID)
    else
      InterestAudience.where("parent_audience_id = ?", 0)
    end
  end
  
  def self.sub_interests(parent_id)
    sub_ids = InterestAudience.sub_interest_ids(parent_id.to_s)
    InterestAudience.where("audience_id in (?) and client_id = ?", sub_ids, INTEREST_CLIENT_ID)
  end
  
  
  def self.interests_from_sub(sub_ids)
    InterestAudience.where("audience_id in (?)", sub_ids).collect(&:parent_audience_id).uniq
  end  
  
  def self.sub_interest_ids(parent_id)
    InterestAudience.where("parent_audience_id = ?", parent_id).collect(&:audience_id)
  end
  
  def self.interest_detail(interest_ids=[])
    interest_audiences = InterestAudience.where("audience_id in (?)", interest_ids)
    result = {}
    gender = []
    age = []
    geo = []
    api_keywords = []
    interest_audiences.each{|ia| api_keywords += ia.keywords.to_s.split("&|&")}
    
    options = "{keyword:#{api_keywords},gender:#{gender},age:#{age},geo:#{geo}}"
    escape_options = URI.escape(options, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
    url = "#{QUERY_URL}?data=#{escape_options}"
    response = nil
    response = HTTParty.get(url)
    # response = HTTParty.get(URI::encode(url))
    data = response.parsed_response
    
    obj = data["aggregations"]["cnt"]
    result = InterestAudience.api_result(obj, 0)
    result
  end
  
  def self.api_result(option,id)
    result = {}
    
    result["id"] = id.to_s
    
    result["audience"] = option["doc_count"]
    location = {}
    
    option["all_country_city"]["buckets"][0..9].each{|lo| location[lo["key"]] = lo["doc_count"] if lo["key"] != "UNKNOWN"}
    location_city = location.keys
    if location.size < 10
      supply_location = ["CN_BJ","CN_SH","CN_GD","CN_ZJ","CN_TJ","CN_JS","CN_FJ","CN_SD","CN_SC","CN_CQ"]
      supply_location = supply_location - location_city
      supply_location[0..(10 - location.size - 1)].each{|sl| location[sl] = 0}
    end
    location = location.sort_by {|k,v| v}.reverse
    result["location"] = InterestAudience.i18n_map(location,"location")
     
    age_group = {}
    age_options = ["18-24","25-34","35-44","45-54","55-64","65+"]
    option["all_age_group"]["buckets"].each{|age| age_group[age["key"]] = age["doc_count"] if age_options.include?(age["key"])}
    age_options.each{|age| age_group[age] = 0 unless age_group[age].present? }
    result["age_group"] = age_group
     
    gender_group = {}
    gender_options = ["f", "m"]
    option["all_gender"]["buckets"].each{|gender| gender_group[gender["key"]] = gender["doc_count"] if gender_options.include?(gender["key"])}
    gender_options.each{|gender| gender_group[gender] = 0 unless gender_group[gender].present?}
    result["gender"] = InterestAudience.i18n_map(gender_group,"gender")
    
     
    interest = {}
    option["all_interests"]["buckets"][0..4].each{|int| interest[int["key"].gsub(/\&|\-/, "_")] = int["doc_count"]}
    if interest.size < 1
      supply_interest = ["arts_entertainment","commerce","food_beverages","fashion","internet_technology"]
      supply_interest.each{|si| interest[si] = 0}
    end
    result["interst"] = InterestAudience.i18n_map(interest,"interest")
     
    device_group = {}
    device_options = ["PC","Tablet","Mobile"]
    option["all_device"]["buckets"].each{|de| device_group[de["key"]] = de["doc_count"] if device_options.include?(de["key"])}
    device_options.each{|device| device_group[device] = 0 unless device_group[device].present? }
    result["device"] = device_group
    
    return result
  end
  
  def self.i18n_map(group={}, m_type)
    group_with_name = {}
    group.each{|k,v| group_with_name[k] = {"name" => InterestAudience.to_i18n("custom_groups.#{m_type}.#{k}", k) , "value" => v}}
    group_with_name
  end
  
  def self.to_i18n(str,k)
    tran_str = ""
    begin I18n.t(str, :raise => true)
      tran_str = I18n.t(str)
    rescue I18n::MissingTranslationData
      tran_str = k.split("_").map(&:capitalize).join(' ')
    end
    tran_str
  end
  
  
  
  
end
