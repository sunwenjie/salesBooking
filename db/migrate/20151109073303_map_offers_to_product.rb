class MapOffersToProduct < ActiveRecord::Migration
  def change
    add_column :advertisements, :product_id, :integer
    ad_type_hash ={
    "VA15"=> "PC平台 - 视频广告 前贴片 15秒",
    "WIN"=>  "PC平台 - 富媒体 视窗Ad TV",
    "PIP"=> "PC平台 - 富媒体 画中画PIP",
    "MIX"=>  "PC平台 - 富媒体 混投",
    "BAN"=>  "PC平台 - 通栏横幅广告及其他形式",
    "QQSpace"=> "PC平台 - QQ空间通栏横幅广告",
    "MOBILE"=> "移动广告",
    "APPVA15"=> "移动平台 - 视频广告 前贴片 15秒",
    "ACROSS"=> "移动平台 - In app 通栏横幅广告",
    "TABLE"=>  "移动平台 - In app 插屏通栏横幅广告",
    "APPMIX"=> "移动平台 - 通栏横幅广告 + 插屏混投",
    "QQMessage"=> "移动平台 - 手机QQ消息流、微信/手机QQ空间/手机QQ Banner",
    "MobileBannersAndWecat"=> "移动平台 - 移动广告(包括微信)",
    "InFeedAdvertisingANDQQ"=> "移动平台 - In Feed广告(包括QQ)",
    "OTV"=> "PC平台 - 海外OTV",
    "VA30"=>"PC平台 - 视频广告 前贴片 30 秒",
    "WecatAndQQ"=> "移动平台 - 微信/手机QQ空间/手机QQ Banner",
    "OTHERTYPE"=> "其他"}
    Offer.all.each{|o|
      product = Product.new()
      ad_type = o.ad_type
      if ad_type.present?
      if (ad_type.include? "CPM") || (ad_type.include? "CPC") || (ad_type.include? "CPE")
        ad_type= ad_type[0,ad_type.length-3]
      end
      else
        ad_type = ""
      end
      product.ad_platform = o.ad_platform
      product.product_type = o.ad_type
      product.name = o.ad_type.present? ? ad_type_hash[ad_type] : ""
      product.regional = o.regional
      product.public_price = o.public_price
      product.general_discount = o.general_discount
      product.floor_discount = o.floor_discount
      product.ctr_prediction = o.ctr_prediction
      product.currency = o.currency
      product.executive_team = 48
      product.approval_team = 44
      product.is_delete = true
      if ["VA15","WIN","PIP","MIX","BAN"].include? o.ad_type
        product.is_distribute_gp = true
        if o.ad_type == "BAN"
          product.product_gp_type = "DSP" 
        elsif o.ad_type == "MIX"
          product.product_gp_type = "MIX"
        else
          product.product_gp_type = "PMP" 
        end

        if o.ad_type == "VA15"
          product.product_xmo_type = "Preroll-15s"
        elsif o.ad_type == "WIN"
          product.product_xmo_type = "AdTV"
        elsif o.ad_type == "PIP"
          product.product_xmo_type = "PIP"
        elsif o.ad_type == "PC-OTV(30s)"
          product.product_xmo_type = "Pre-roll-30s"
        end
        
      else
        product.is_distribute_gp = false
      end
      product.save(:validate=>false)
    }
     count = 0
    Advertisement.all.each{|a|
      regional = a.order.present? ?  a.order.regional : ""
      if regional == "SPECIAL_COUNTRY" || regional == "SPECIAL_CITY"
        product = Product.find_by(product_type:a.ad_type,ad_platform:a.ad_platform)
      else
        product = Product.find_by(regional:regional,product_type:a.ad_type,ad_platform:a.ad_platform)
      end
      if product.present?
      product.sale_model = a.present? ? (a.cost_type.present? ? a.cost_type : "") :""
      product.save(:validate=>false)
      a.product_id= product.id
      a.save(:validate=>false)
      else
        p "order:0000000000000000000"
        p a.id
        #count +=1
      end
    }

  end
end
