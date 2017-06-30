module OffersHelper

  def options_for_offer_regional
    options = [["全部","NATION"],["美国,英国,澳洲,新西兰,马来西亚","US_UK_AU_NZ_MY"],["香港,台湾,澳门,新加坡","HK_TW_MA_SG"],["北上广深","SPECIAL"],["其他","OTHER"],["其他国家","OTHER_COUNTRY"],["自定义国家组合","SPECIAL_COUNTRY"]]
    selected=@offer.present? ? @offer.regional : ["NATION"]
    options_for_select(options,selected)
  end

  def options_for_offer_ad_platform
    options = [["移动广告","MOBILE"],["PC展示广告","COMPUTER"]]
    selected=@offer.present? ? @offer.ad_platform : ["COMPUTER"]
    options_for_select(options,selected)
  end

  def options_for_offer_ad_type
    options = []
    selected=@offer.present? ? @offer.ad_type : ["VA15"]
    options += ProductType.all.collect{|type| [type.name,type.ad_type]}
    options_for_select(options,selected)
  end
end
