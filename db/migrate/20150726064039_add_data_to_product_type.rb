class AddDataToProductType < ActiveRecord::Migration
  def change
    options = [["PC平台 - 视频广告 前贴片 15秒","VA15"],["PC平台 - 富媒体 视窗Ad TV","WIN"],["PC平台 - 富媒体 画中画PIP","PIP"],["PC平台 - 富媒体 混投","MIX"],
               ["PC平台 - 通栏横幅广告及其他形式","BAN"],["PC平台 - QQ空间通栏横幅广告","QQSpace"],["移动平台 - 视频广告 前贴片 15秒","APPVA15"],["移动平台 - In app 通栏横幅广告","ACROSS"],
               ["移动平台 - In app 插屏通栏横幅广告","TABLE"],
               ["移动平台 - 通栏横幅广告 + 插屏混投","APPMIX"],["移动平台 - 手机QQ消息流、微信/手机QQ空间/手机QQ Banner","QQMessage"],["移动平台 - 微信/手机QQ空间/手机QQ Banner","WecatAndQQ"],["移动平台 - 移动广告(包括微信)","MobileBannersAndWecat"],["移动平台 - In Feed广告(包括QQ)","InFeedAdvertisingANDQQ"]
    ]
    options.each{|option|
    ProductType.create(:name =>option[0],:ad_type=>option[1])
    }
  end
end
