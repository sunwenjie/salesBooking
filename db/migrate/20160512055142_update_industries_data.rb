class UpdateIndustriesData < ActiveRecord::Migration
  def change
    industries = [
        {:name => "汽车",:name_en => "Automobile & Petroleum",:code => "AP"},
        {:name => "纤体美容",:name_en => "Beauty Salon & Fitness Centre",:code => "BF"},
        {:name => "投资理财",:name_en => "Banking, Finance & Investment",:code => "BI"},
        {:name => "专业服务",:name_en => "Business & Professional Services",:code => "BP"},
        {:name => "化妆品",:name_en => "Cosmetics & Skincare",:code => "CS"},
        {:name => "电脑",:name_en => "Computer & Software",:code => "CW"},
        {:name => "电子产品",:name_en => "Electronics & Digital Devices",:code => "ED"},
        {:name => "教育",:name_en => "Education & Training",:code => "ET"},
        {:name => "饮食",:name_en => "Food & Beverage",:code => "FB"},
        {:name => "家具",:name_en => "Furniture & Housewares",:code => "FH"},
        {:name => "时装",:name_en => "Fashion",:code => "FN"},
        {:name => "外汇",:name_en => "Foreign Exchange",:code => "FX"},
        {:name => "娱乐",:name_en => "Gaming, Entertainment & Media",:code => "GM"},
        {:name => "组织",:name_en => "Government & Non-Commercial Organization",:code => "GO"},
        {:name => "黄金贸易",:name_en => "Gold Trade",:code => "GT"},
        {:name => "酒店",:name_en => "Hotel",:code => "HL"},
        {:name => "家居用品",:name_en => "Household Toiletries",:code => "HT"},
        {:name => "保险",:name_en => "Insurance",:code => "IS"},
        {:name => "物流",:name_en => "Logistics",:code => "LG"},
        {:name => "其他",:name_en => "Miscellaneous",:code => "MC"},
        {:name => "制造",:name_en => "Manufacturing",:code => "MF"},
        {:name => "电子商贸",:name_en => "Online Shop & eCommerce",:code => "OE"},
        {:name => "医疗保健",:name_en => "Pharmaceuticals & Healthcare",:code => "PH"},
        {:name => "高級消費品",:name_en => "Premium & Luxury",:code => "PL"},
        {:name => "房地产",:name_en => "Property, Real Estate & Agent",:code => "PR"},
        {:name => "第三方支付平台",:name_en => "Payment Services",:code => "PS"},
        {:name => "零售百货",:name_en => "Retails, Chain & Department Store",:code => "RC"},
        {:name => "住宅服务",:name_en => "Residential Services",:code => "RS"},
        {:name => "餐馆",:name_en => "Restaurants",:code => "RT"},
        {:name => "证券",:name_en => "Securities",:code => "SC"},
        {:name => "运动用品",:name_en => "Sports & Sports Wear",:code => "SS"},
        {:name => "旅游",:name_en => "Travel",:code => "TL"},
        {:name => "交通航空",:name_en => "Transportation ",:code => "TP"},
        {:name => "电讯",:name_en => "Telecommunications Services",:code => "TS"},
        {:name => "钟表珠宝",:name_en => "Watch & Jewelry",:code => "WJ"},
        {:name => "贵金属贸易",:name_en => "Precious Metal Trading",:code => "PM"},
        {:name => "母婴育儿",:name_en => "Maternity & Babies",:code => "MB"},
        {:name => "军事资讯",:name_en => "Military Insights",:code => "MI"},
        {:name => "门户资讯",:name_en => "Information Services",:code => "IN"},
        {:name => "家装建材",:name_en => "Renovation & Decor",:code => "RD"}
    ]
    map_old_industry = {"娱乐"=>["休闲娱乐"],"运动用品"=>["体育运动"],"专业服务"=>["生活服务"],"教育"=>["教育培训"],"投资理财"=>["金融财经"],
    "其他"=> ["其他"],"电子产品"=>["视频影音","消费数码"],"旅游"=>["旅游交通"],"时装"=>["流行时尚"],"母婴育儿"=>["母婴育儿"],
    "汽车"=>["汽车资讯"],"军事资讯"=>["军事资讯"],"医疗保健"=>["健康医疗"],"门户资讯"=>["门户资讯"],"家装建材"=>["家装建材"]}

        industries.each{|industry|
                       name = industry[:name]
                       if map_old_industry["#{name}"].present?
                         map_old_industry["#{name}"].each do |old_i|
                           industry_old = Industry.find_by_name old_i
                           industry_old.update_attributes({:name => name,:name_en => industry[:name_en],:code => industry[:code]}) if industry_old.present?
                         end
                       else
                       Industry.create industry
                       end
                       }

  end
end
