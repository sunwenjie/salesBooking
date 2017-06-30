module ClientsHelper

  def options_for_channels(client)
    sql = " SELECT DISTINCT channels.channel_name, channels.id, currencies.id currency_id,currencies.name as currency_name
              FROM channels
              left join xmo.currencies on channels.currency_id = currencies.id
              left join user_channels on channels.id = user_channels.channel_id
              WHERE (is_delete is null) "

    (current_user.administrator? || current_user.direct_sale? ) ? sql : sql += " and user_channels.user_id = #{current_user.id}"

    if  !@client.new_record?
      sql += " or channels.id = #{client.channel}" if (client.present? && client.channel.present?)
    end

    sql += " ORDER BY channel_name "
    all_agencys =  Channel.find_by_sql(sql) || []
  end


  def options_for_industry(client)
    selected = @client.industry_id || ''
    if @client.new_record?
      sql = "select name,name_cn,max(id) as id  from industries group by name,name_cn"
    else

      selected_name_cn = selected.blank? ? '' : (Industry.find selected).name_cn
      sql = "select name,name_cn,max(id) as id  from industries where name_cn != '#{selected_name_cn}' group by name,name_cn
             union all select name,name_cn,id from industries where id = '#{selected}'"
    end
    options = [[t('clients.show.select_channel'),""]]
    options += I18n.locale.to_s == 'en' ? Industry.find_by_sql(sql).map{|x| [x.name,x.id]} : Industry.find_by_sql(sql).map{|x| [x.name_cn,x.id]}

    options_for_select(options, selected)
  end

  def options_for_transfer
    selected =  @client.user_id
    options = User.where.not(user_status: "Stopped").eager_load(:agency).order("binary trim(users.name)").map{|x| [x.name + " ("+(x.agency.name rescue '')+")",x.id]}
    options_for_select(options, selected)
  end

  def option_for_sap_channels(sap_channels)
    options = [["请选择",""],["代理-A","101"],["直接客戶-DC","102"],["经销商-R","103"]]
    options_for_select(options,sap_channels.present? ? sap_channels:options[0])
  end


  def option_for_country(country)
    options = [["请选择",""],["中国","CN"]]
    options_for_select(options,country.present? ? country:options[0])
  end

  def option_for_province(province)
    options = [["请选择",""],["北京", "010"], ["上海", "020"], ["天津", "030"], ["内蒙古", "040"], ["山西", "050"], ["河北", "060"],
               ["辽宁", "070"], ["吉林", "080"], ["黑龙江", "090"], ["江苏", "100"], ["安徽", "110"], ["山东", "120"],
               ["浙江", "130"], ["江西", "140"], ["福建", "150"], ["湖南", "160"], ["湖北", "170"], ["河南", "180"],
               ["广东", "190"], ["海南", "200"], ["广西", "210"], ["贵州", "220"], ["四川", "230"], ["云南", "240"],
               ["陕西", "250"], ["甘肃", "260"], ["宁夏", "270"], ["青海", "280"], ["新建", "290"], ["西藏", "300"],
               ["重庆", "320"], ["HongKong", "330"], ["Macao", "340"]]

    options_for_select(options,province.present? ? province:options[0])
  end

  # def option_for_currency(currency)
  #   options = [["请选择",""],["澳大利亚元","AUD"],["人民币","CNY"],["欧元","EUR"],["英镑","GBP"],["港币","HKD"],["新加坡元","SGD"],["新台币","TWD"],["美元","USD"]]
  #   options_for_select(options,currency.present? ? currency:options[0])
  # end
  def option_for_sale_channel_client(sale_channel)
    options =[["请选择",""],["直销","01"]]
    options_for_select(options,sale_channel.present? ? sale_channel : options[0])
  end

  def option_for_sale_origanize_client(sale_origanize)
    options =[["请选择",""],["BJ-內部公司:iClick HK", "11210901"], ["BJ-內部公司:PMG HK", "11210902"], ["BJ-內部公司:Tetris HK", "11210903"], ["BJ-內部公司:CSA HK", "11210904"],
              ["BJ-內部公司:搜索亞洲科技(深圳)有限公司", "11210905"], ["SH-內部公司:iClick HK", "11310901"], ["SH-內部公司:PMG HK", "11310902"],
              ["SH-內部公司:Tetris HK", "11310903"], ["SH-內部公司:CSA HK", "11310904"], ["SH-內部公司:搜索亞洲科技(深圳)有限公司", "11310905"], ["BJ-技术部", "112113"],
              ["SH-技术部", "113113"], ["BJ-Direct sale（BJ）直客销售部-华北", "11210501"], ["BJ-Direct sale（SH）直客销售部-华东", "11210502"],
              ["BJ-Direct sale（GZ）直客销售部-华南", "11210503"], ["BJ-SEM sale（CN）搜索销售部", "11210504"], ["BJ-Channel sale 渠道销售部", "11210505"],
              ["BJ-Sales Strategy Planning 销售策划部", "11210506"], ["BJ-Creative Design 创意设计部", "11210507"], ["BJ-Biz Operations - Search 业务运营", "11210508"],
              ["BJ-Biz Operations - Non Search  业务运营", "11210509"], ["BJ-Sales Operation 销售运营部", "11210510"], ["BJ-Int'l Biz & Access 海外客户运营部", "11210511"],
              ["BJ-Media (Non- Search)", "11210512"], ["BJ-Media (Search)", "112108"], ["SH-Media (Search)", "113108"], ["SH-Direct sale（BJ）直客销售部-华北", "11310501"],
              ["SH-Direct sale（SH）直客销售部-华东", "11310502"], ["SH-Direct sale（GZ）直客销售部-华南", "11310503"], ["SH-SEM sale（CN）搜索销售部", "11310504"],
              ["SH-Channel sale 渠道销售部", "11310505"], ["SH-Sales Strategy Planning 销售策划部", "11310506"], ["SH-Creative Design 创意设计部", "11310507"],
              ["SH-Biz Operations - Search 业务运营", "11310508"], ["SH-Int'l Biz & Access 海外客户运营部", "11310510"], ["SH-Sales Operation 销售运营部", "11310511"], ["SH-Media (Non- Search)", "11310512"]]

    options_for_select(options,sale_origanize.present? ? sale_origanize:options[0])
  end

  def option_for_company_number(company_number)
    options =[["请选择",""],["Optimix Media  Asia Limited (HK)", "11"], ["Digital Marketing Group Limited (HK)", "112"], ["爱点击互动（北京）广告有限公司", "1121"],
              ["Tetris Media Limited (HK)", "113"], ["泰司广告（上海）有限公司", "1131"], ["爱点击科技（北京）有限公司", "114"],
              ["Performance Media Group Limited (HK)", "115"], ["IClick Interactive Asia Limited (HK)", "116"],
              ["China Search (Asia) Limited (HK)", "1211"], ["搜索亚洲科技(深圳)有限公司", "12111"], ["擘纳(上海)信息科技有限公司", "131"]]

    options_for_select(options,company_number.present? ? company_number:options[0])
  end

  def option_for_pay_condition_client(pay_condition)
    options = [["请选择",""],["立即全额付款","1001"],["30 天到期全额付款","1003"],["45 天到期全额付款","1004"],["60 天到期全额付款","1005"],["7 天到期全额付款","Z001"],["15 天到期全额付款","Z002"],["90 天到期全额付款","Z003"]]
    options_for_select(options,pay_condition.present? ? pay_condition : options[0])
  end

  def option_for_pay_type(pay_type)
    options = [["请选择",""],["银行转账","05"],["支票","06"]]
    options_for_select(options,pay_type.present? ? pay_type : options[0])
  end

  def option_for_industry_detail(industry_detail)
    options = [["请选择",""],["AP-汽车", "101"], ["BF-纤体美容", "102"], ["BI-投资理财", "103"], ["BP-专业服务", "104"], ["CS-化妆品", "105"], ["ED-电子产品", "106"], ["ET-教育", "107"], ["FB-饮食", "108"], ["FH-家具", "109"],
               ["FN-时装", "110"], ["FX-外汇", "111"], ["GM-娱乐", "112"], ["HL-酒店", "113"], ["HT-家居用品", "114"], ["IS-保险", "115"], ["MF-制造", "116"], ["OE-电子商贸", "117"], ["PH-医疗保健", "118"],
               ["PL-高級消費品", "119"], ["PM-贵金属贸易", "120"], ["RC-零售百货", "121"], ["RS-住宅服务", "122"], ["SC-证券", "123"], ["TP-交通航空", "124"], ["TS-电讯", "125"], ["WJ-钟表珠宝", "126"],
               ["CW-电脑", "127"], ["GO-组织", "128"], ["GT-黄金贸易", "129"], ["LG-物流", "130"], ["PR-房地产", "131"], ["PS-第三方支付", "132"], ["RT-餐馆", "133"], ["SS-运动用品", "134"], ["TL-旅游", "135"], ["MC-其他", "136"]]
    options_for_select(options,industry_detail.present? ? industry_detail : options[0])
  end

  def option_for_client_invoice_type_client(client_invoice_type)
    options =[["请选择",""],["增值税专用发票","101"],["增值税普通发票","102"],["形式发票","103"]]
    options_for_select(options,client_invoice_type.present? ? client_invoice_type : options[0])
  end

  def option_for_deal_people(deal_people)
    options =[["请选择",""],["第三方","4010"],["内部关联企业","4030"],["第三方-供应商返点","Z09"],["内部关联企业-供应商返点","Z11"]]
    options_for_select(options,deal_people.present? ? deal_people : options[0])
  end

  def options_for_client_currency(current_currency_id)
    options = Currency.all.map{|c| [c.name,c.id]}
    options_for_select(options,current_currency_id.present? ? current_currency_id : 2)
  end

  def client_node_class(status)
    if status == "approved"
      "status-ready"
    elsif status == "cli_rejected"
      "status-error"
    elsif status == "unapproved" || status == "cross_unapproved"
      "status-submit"
    else
      ""
    end
  end

  def display_item(value)
    value.present? ? value : '-'
  end

end
