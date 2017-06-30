module OrdersHelper
  def options_for_media_industry
    options = []
    options = [["全选", 'ALL']]
    for range in 1..16
      options += [[t("media.website_industry#{range}"), range.to_s]]
    end
    options_for_select(options, "ALL")
  end

  def status_label(index,status,order)
    p 7777777
    p index
    p status
    status.delete_at(7)
    is_jast_for_gp = order.is_jast_for_gp
    is_gp_finish = order.is_gp_commit
    map_state = ""
    map_order_flows = [
        {"0"=>t("order.status.wait_submit"),"1"=>[t("order.status.pre_sale_check"),t("order.status.pre_sale_check_gp"),t("order.status.pre_sale_check_gp_finish")],"2"=>[t("order.status.pre_sale_checked"),t("order.status.pre_sale_finish_gp"),t("order.status.pre_sale_check_gp_checked")],"3"=>t("order.status.pre_sale_unchecked")},
        {"1"=>t("order.flow.gp_control_submit"),"2" => t("order.flow.unsupport_gp")},
        {"1"=>t("order.status.approving01"),"2"=>t("order.status.approved"),"3"=>t("order.status.unapproved")},
        {"1"=>t("order.status.approving02"),"2"=>t("order.status.approved02"),"3"=>t("order.status.unapproved02")},
        {"1"=>t("order.flow.schedule_list_submit"),"2" => t("order.flow.schedule_list_unsubmit")},
        {"1"=>t("order.status.contract_approving"),"2"=>t("order.status.contract_approved"),"3"=>t("order.status.contract_unapproved")},
        {"0"=>t("order.status.am_wait_undistribute"),"1"=>t("order.status.am_wait_distribute"),"2"=>t("order.status.am_distributed")}]
    if index == 0
        if is_jast_for_gp
          if status[0] == "1"
            map_state = map_order_flows[0]["1"][2] if is_gp_finish
            map_state = map_order_flows[0]["1"][1] if !is_gp_finish
          elsif status[0] == "2"
            map_state = map_order_flows[0]["2"][2] if is_gp_finish
            map_state = map_order_flows[0]["2"][1] if !is_gp_finish
          else
            map_state = map_order_flows[0][status[0]]
          end
        else
          if status[0] == "1"
            map_state = map_order_flows[0]["1"][0]
          elsif status[0] == "2"
            map_state = map_order_flows[0]["2"][0]
          else
            map_state = map_order_flows[0][status[0]]
          end
        end
    else
      if status[index].to_s == "0"
      if index == 3
        index = index - 2
        map_state = last_node_state(map_order_flows,status,index,is_jast_for_gp,is_gp_finish)
      else
        index = index - 1
        map_state =  last_node_state(map_order_flows,status,index,is_jast_for_gp,is_gp_finish)
      end
      else
        map_state =  map_order_flows[index][status[index]]
      end
    end
    return map_state
  end

  def last_node_state(map_order_flows,status,index,is_jast_for_gp,is_gp_finish)
    m = "0"
    j = 0
    flow_index = 0
    last_map_state = ""
    status[0..index].reverse.each_with_index do |s,i|
      m = s
      j = i
      flow_index = index - j
      break if s.to_i > 0 &&  !(flow_index == 1 && s == "2")
    end
    if flow_index == 0
      if is_jast_for_gp
        if m == "1"
          last_map_state = map_order_flows[0]["1"][2] if is_gp_finish
          last_map_state = map_order_flows[0]["1"][1] if !is_gp_finish
        elsif m == "2"
          last_map_state = map_order_flows[0]["2"][2] if is_gp_finish
          last_map_state = map_order_flows[0]["2"][1] if !is_gp_finish
        else
          last_map_state = map_order_flows[0][status[0]]
        end
      else
        if m == "1"
          last_map_state = map_order_flows[0]["1"][0]
        elsif m == "2"
          last_map_state = map_order_flows[0]["2"][0]
        else
          last_map_state = map_order_flows[0][status[0]]
        end
      end
    else
      last_map_state = map_order_flows[flow_index][m]
    end
    return  last_map_state
  end

  def order_approval_flow_status(status,index,is_non_standart)
    status = status.split(',')
    if is_non_standart
      status.delete_at(1)
    else
      status.delete_at(2)
    end
    result = []

    if status.present?
      status.each do |item|
        case item
        when "0"
          result << ''
        when "1"
          result << 'status-submit'
        when "2" << ''
          result << 'status-ready'
        when "3" 
          result << 'status-error'
        else
          result << ''
        end
      end
      
    end
    result[index]
  end

  def color_class_for_distribute(operations,status)
    status = status.split(",")
     color_class = ""
     if  operations.present? && status[-2] != "0"
       last_operations = operations.last
       if last_operations.action == "config_done"
        color_class = "status-ready"
       else
         color_class = "status-submit"
       end
     end
   return color_class
  end

  def options_for_sale_groups
    groups =  Group.where("status = ? and id in (?)","Active",@sale.user_group_ids).pluck(:name)
    options_for_select(groups,groups)
  end
 
  def options_for_media_ad_format
    options = []
    options = [["全选", 'ALL']]
    for range in 1..2
      options += [[t("media.website_ad_format#{range}"), range.to_s]]
    end
    options_for_select(options, "ALL")
  end

  def options_for_interests
    options = [["请选择", ""]]
    options += InterestAudience.interests(nil).sort_by{|b| b.name}.collect{|bsin| [bsin.name, bsin.audience_id.to_s]}
    options_for_select(options, nil)
  end


  def options_for_empty(countries = nil)
    options = [[t('order.form.china_option'), "CHINA"],[t('order.form.us_uk_au_nz_my'),"US_UK_AU_NZ_MY"],[t('order.form.hk_tw_ma_sg'),"HK_TW_MA_SG"],[t('order.form.other_country'),"OTHER_COUNTRY"],[t('order.form.special_country'),"SPECIAL_COUNTRY"]]
    options_for_select(options, [])
  end

  def options_for_china(countries = nil)
    options = [[t('order.form.china_option'), "china"],[t('order.form.us_uk_au_nz_my'),"US_UK_AU_NZ_MY"],[t('order.form.hk_tw_ma_sg'),"HK_TW_MA_SG"],[t('order.form.other_country'),"OTHER_COUNTRY"],[t('order.form.special_country'),"SPECIAL_COUNTRY"]]
    options_for_select(options, ["china"])
  end

  def options_for_us_uk_au_nz_my(countries = nil)
    options = [[t('order.form.china_option'), "CHINA"],[t('order.form.hk_tw_ma_sg'),"HK_TW_MA_SG"],[t('order.form.other_country'),"OTHER_COUNTRY"],[t('order.form.special_country'),"SPECIAL_COUNTRY"],[t('order.form.us'),"US"],[t('order.form.uk'),"UK"],[t('order.form.au'),"AU"],[t('order.form.nz'),"NZ"],[t('order.form.my'),"MY"]]
    options_for_select(options, countries ? countries : ["US","UK","AU","NZ","MY"])
  end

  def options_for_hk_tw_ma_sg(countries = nil)
    options = [[t('order.form.china_option'), "CHINA"],[t('order.form.us_uk_au_nz_my'),"US_UK_AU_NZ_MY"],[t('order.form.other_country'),"OTHER_COUNTRY"],[t('order.form.special_country'),"SPECIAL_COUNTRY"],[t('order.form.hk'),"HK"],[t('order.form.tw'),"TW"],[t('order.form.ma'),"MA"],[t('order.form.sg'),"SG"]]
    options_for_select(options, countries ? countries : ["HK","TW","MA","SG"])
  end

  def options_for_other_country(countries = nil)
    options = [[t('order.form.china_option'), "CHINA"],[t('order.form.us_uk_au_nz_my'),"US_UK_AU_NZ_MY"],[t('order.form.hk_tw_ma_sg'),"HK_TW_MA_SG"],[t('order.form.other_country'),"other_country"],[t('order.form.special_country'),"SPECIAL_COUNTRY"]]
    options_for_select(options, ["other_country"])
  end

  def options_for_special_country(countries = nil)
    options = [[t('order.form.china_option'), "CHINA"],[t('order.form.us_uk_au_nz_my'),"US_UK_AU_NZ_MY"],[t('order.form.hk_tw_ma_sg'),"HK_TW_MA_SG"],[t('order.form.other_country'),"OTHER_COUNTRY"],[t('order.form.special_country'),"special_country"]]
    options_for_select(options, ["special_country"])
  end

  def options_for_special_countrys(countries = nil)
    options = [[t('order.form.china_option'), "all_countrys"]]+Order::TRY_OPTIONS
    options_for_select(options, countries ? countries : ["all_countrys"])
  end


  def options_for_bshare_delivery_type
    options = [[t('order.form.please_select'), ""]]
    for range in 1..3
      options += [[t("geo_delivery_type#{range}"), range.to_s]]
    end
    options
  end


  def options_for_bshare_province
    options = []
    options = [[t('order.form.all_country'), 'all_provinces']]
    provinces = Province.all
    options += provinces.sort_by{|p| p.name}.collect{|p| [I18n.locale == :en ? p.name : p.name_cn, p.code_id.to_s]}

    options
  end


  def options_for_bshare_city_level
    options = []
    options = [[t('order.form.all_country'), 'all_city_level']]
    for range in 1..4
      options += [[t("layout.city_level#{range}"), range.to_s]]
    end
    options
  end

  
  def options_for_bshare_mainland(selected = nil)
    cities = City.all(:conditions => "name_key is not null").sort{|x, y| x.name <=> y.name}
    cities.inject([[t('order.form.all_country'), 'all_cities']]){|x, city| x << [city.name , city.name_key]}
  end

  #加载订单用户对应BU产品
  def order_bu_product(actionname=nil,product_type=nil,product_id=nil)
    order_user = (@order && @order.id.present?) ? @order.user : current_user
     if %w(new edit update create).include? actionname
        products = order_user.send("self_bu_adcombo_new",product_type)
        products << [Product.find(product_id).name, product_id] if actionname != 'new' && product_id && Product.find(product_id).is_delete == true
        products
     else
        order_user.send("self_bu_adcombo_show",product_id) 
     end
  end
  
  def options_for_ad_type(actionname,ad_type=nil,product = nil)
    order_user = (@order && @order.id.present?) ? @order.user : current_user
     if %w(new edit update create).include? actionname
        product_category = order_user.self_bu_adtype_new
        product_category << [I18n.locale.to_s == "en" ? product.product_type_en : product.product_type_cn, product.product_type] if product && product.is_delete == true
        product_category
     else
        [ad_type,ad_type]
     end
  end
  
  def city_mapping
    {"all_cities"=>"全部","BJ"=>"北京","SH"=>"上海","TJ"=>"天津","CQ"=>"重庆","TW"=>"台湾","HK"=>"香港","MO"=>"澳门","SJZ"=>"石家庄","BD"=>"保定","ZJK"=>"张家口","CD221"=>"承德","CZ1"=>"沧州","HD21"=>"邯郸","XT22"=>"邢台","QHD"=>"秦皇岛","TY"=>"太原","SZ411"=>"朔州","XZ11"=>"忻州","DT"=>"大同","YQ"=>"阳泉","CZ24"=>"长治","LF21"=>"临汾","JZ41"=>"晋中","LL32"=>"吕梁","YC42"=>"运城","CD1"=>"成都","PZH"=>"攀枝花","ZG"=>"自贡","MY"=>"绵阳","NC211"=>"南充","DZ211"=>"达州","SN22"=>"遂宁","GA31"=>"广安","BZ111"=>"巴中","LZ211"=>"泸州","YB"=>"宜宾","NJ41"=>"内江","LS41"=>"乐山","DY22"=>"德阳","TS21"=>"唐山","LF23"=>"廊坊","HS23"=>"衡水","HHHT"=>"呼和浩特","BT"=>"包头","WH131"=>"乌海","CF"=>"赤峰","TL12"=>"通辽","EEDS"=>"鄂尔多斯","HLBE"=>"呼伦贝尔","WLCB"=>"乌兰察布","SY32"=>"沈阳","DL"=>"大连","AS11"=>"鞍山","BX"=>"本溪","DD"=>"丹东","JZ311"=>"锦州","HLD"=>"葫芦岛","YK"=>"营口","PJ"=>"盘锦","FX"=>"阜新","LY221"=>"辽阳","TL33"=>"铁岭","CC"=>"长春","LY223"=>"辽源","TH"=>"通化","BS21"=>"白山","SY12"=>"松原","BC"=>"白城","YBCX"=>"延边","HEB"=>"哈尔滨","QQHE"=>"齐齐哈尔","HG43"=>"鹤岗","SYS"=>"双鸭山","JX111"=>"鸡西","DQ"=>"大庆","MDJ"=>"牡丹江","JMS"=>"佳木斯","QTH"=>"七台河","HH12"=>"黑河","SH4"=>"绥化","DXAL"=>"大兴安岭","NJ21"=>"南京","WX"=>"无锡","XZ21"=>"徐州","CZ211"=>"常州","NT"=>"南通","LYG"=>"连云港","HA"=>"淮安","YC22"=>"盐城","YZ21"=>"扬州","ZJ411"=>"镇江","SQ41"=>"宿迁","SZ11"=>"苏州","HZ211"=>"杭州","NB"=>"宁波","WZ11"=>"温州","JX112"=>"嘉兴","HZ212"=>"湖州","SX"=>"绍兴","JH"=>"金华","QZ211"=>"衢州","ZS111"=>"舟山","TZ"=>"台州","LS43"=>"丽水","HF"=>"合肥","WH22"=>"芜湖","BB"=>"蚌埠","HN"=>"淮南","MAS"=>"马鞍山","HB23"=>"淮北","TL22"=>"铜陵","AQ"=>"安庆","HS21"=>"黄山","CZ212"=>"滁州","FY"=>"阜阳","CH"=>"巢湖","HZ12"=>"亳州","ZZ21"=>"池州","XC12"=>"宣城","FZ21"=>"福州","XM"=>"厦门","PT"=>"莆田","SM121"=>"三明","QZ212"=>"泉州","ZZ111"=>"漳州","NP"=>"南平","LY222"=>"龙岩","ND"=>"宁德","NC212"=>"南昌","JDZ"=>"景德镇","PX"=>"萍乡","XY12"=>"新余","JJ"=>"九江","YT121"=>"鹰潭","GZ41"=>"赣州","GA21"=>"吉安","SR"=>"上饶","JN321"=>"济南","QD"=>"青岛","ZB"=>"淄博","ZZ31"=>"枣庄","DY12"=>"东营","WF"=>"潍坊","YT122"=>"烟台","WH132"=>"威海","JN322"=>"济宁","TA"=>"泰安","RZ"=>"日照","LW"=>"莱芜","DZ212"=>"德州","LY224"=>"临沂","LC22"=>"聊城","BZ112"=>"滨州","HZ22"=>"菏泽","ZZ41"=>"郑州","LY42"=>"洛阳","PDS"=>"平顶山","JZ14"=>"焦作","HB44"=>"鹤壁","XX"=>"新乡","AY"=>"安阳","PY"=>"濮阳","XC31"=>"许昌","LH"=>"漯河","SMX"=>"三门峡","NY"=>"南阳","SQ11"=>"商丘","XY42"=>"信阳","ZK"=>"周口","ZKD"=>"驻马店","WH34"=>"武汉","HS22"=>"黄石","XF"=>"襄樊","SY24"=>"十堰","JZ312"=>"荆州","YC212"=>"宜昌","JM121"=>"荆门","EZ"=>"鄂州","XG"=>"孝感","HG21"=>"黄冈","XN22"=>"咸宁","SZ21"=>"随州","CS"=>"长沙","ZZ112"=>"株洲","XT122"=>"湘潭","HY221"=>"衡阳","SY42"=>"邵阳","YY421"=>"岳阳","CD222"=>"常德","ZJJ"=>"张家界","YY422"=>"益阳","BZ113"=>"郴州","HH24"=>"怀化","LD"=>"娄底","GZ31"=>"广州","SZ14"=>"深圳","ZH"=>"珠海","ST"=>"汕头","SG"=>"韶关","FS21"=>"佛山","JM122"=>"江门","ZJ412"=>"湛江","MM"=>"茂名","ZQ"=>"肇庆","HZ411"=>"惠州","MZ"=>"梅州","SW"=>"汕尾","HY222"=>"河源","YJ"=>"阳江","DG"=>"东莞","ZS112"=>"中山","CZ213"=>"潮州","JY22"=>"揭阳","YF"=>"云浮","NN"=>"南宁","LZ31"=>"柳州","GL"=>"桂林","WZ211"=>"梧州","BH"=>"北海","FCG"=>"防城港","QZ11"=>"钦州","GG"=>"贵港","BS34"=>"百色","HZ412"=>"贺州","HC"=>"河池","LB"=>"来宾","CZ23"=>"崇左","HK33"=>"海口","SY14"=>"三亚","GY421"=>"贵阳","LPS"=>"六盘水","ZY141"=>"遵义","AS14"=>"安顺","BJ2"=>"毕节","KM"=>"昆明","QJ34"=>"曲靖","YX"=>"玉溪","ZT"=>"昭通","LJ"=>"丽江","LC21"=>"临沧","XA"=>"西安","TC212"=>"铜川","BJ31"=>"宝鸡","XY22"=>"咸阳","WN422"=>"渭南","YA"=>"延安","HZ413"=>"汉中","YL"=>"榆林","AK"=>"安康","SL"=>"商洛","LZ213"=>"兰州","JC11"=>"金昌","TS13"=>"天水","JYG"=>"嘉峪关","ZY142"=>"张掖","PL"=>"平凉","JQ"=>"酒泉","QY42"=>"庆阳","DX"=>"定西","LN"=>"陇南","XN12"=>"西宁","YC213"=>"银川","SZS"=>"石嘴山","GY422"=>"固原","WLMQ"=>"乌鲁木齐","KLMY"=>"克拉玛依","TLF"=>"吐鲁番","HT"=>"和田","AKS"=>"阿克苏","BYKL"=>"巴音郭楞","BETL"=>"博尔塔拉","TC32"=>"塔城","ALT"=>"阿勒泰","RQ"=>"任丘","JC41"=>"晋城","XLGLM"=>"锡林郭勒盟","BYNE"=>"巴彦淖尔","ALSM"=>"阿拉善盟","XAM"=>"兴安盟","FS34"=>"抚顺","CY"=>"朝阳","JL22"=>"吉林市","SP"=>"四平","TZ41"=>"泰州","SZ412"=>"宿州","LA"=>"六安","YC211"=>"宜春","FZ3"=>"抚州","JY32"=>"济源","XT121"=>"仙桃","TM"=>"天门","QJ31"=>"潜江","SNJ"=>"神农架","YZ31"=>"永州","QY13"=>"清远","YL4"=>"玉林","WZS"=>"五指山","QH"=>"琼海","DZ11"=>"儋州","WC"=>"文昌","WN421"=>"万宁","DF"=>"东方","CM"=>"澄迈","DA"=>"定安","TC211"=>"屯昌","LG"=>"临高","TR"=>"铜仁","BS31"=>"保山","SM122"=>"思茅","LS14"=>"拉萨","NQ"=>"那曲","CD11"=>"昌都","SN12"=>"山南","RKZ"=>"日喀则","AL"=>"阿里","LZ212"=>"林芝","BY"=>"白银","WW"=>"武威","HD11"=>"海东","WZ212"=>"吴忠","ZW"=>"中卫","SHZ"=>"石河子","ALE"=>"阿拉尔","TMSK"=>"图木舒克","WJL"=>"五家渠","HM"=>"哈密","KS"=>"喀什","KZLS"=>"克孜勒苏","YLHS"=>"伊犁哈萨"}
  end

  def examination_infs(obj)
    order_infs = ""
    obj.examinations.where("from_state!='order_saved' and from_state!='planner_approved' and from_state!='proof_ready'").each do |exam|
      unless obj.state == "examine_completed" && exam.to_state == "legal_officer_unapproved"
        # order_infs += exam.created_user+"于"+exam.created_at.localtime.strftime("%Y-%m-%d %H:%M")+"对订单#{exam.from_state == 'planner_unapproved' ? '核对' : '审批' },订单状态改变为: #{t(exam.to_state)} "+ (exam.comment[0]&&exam.comment[0]!="" ? " 说明："+exam.comment[0] : "")+"\n"
        order_infs += t("order.approve_tips", user_name: exam.created_user, time: exam.created_at.localtime.strftime("%Y/%m/%d %H:%M"), handle: exam.from_state == 'planner_unapproved' ? t("order.check") : t("order.approve"), status: t("#{exam.to_state}"), comment: exam.comment[0]&&exam.comment[0]!="" ? t("order.form.order_description") +exam.comment[0] : "")
      end
    end
    order_infs
  end

  # def btn_view_by_state(can_edit)
  #   html ,ele = "",""
  #   ele = get_btn_html if can_edit
  #
  #   if can_edit && @order.state_is?(Order::CALLBACK_EDIT_STATES)
  #     html << %Q( <div class= "outer_cancel"> <a class='cancel cancel_pretargeting change_cancel_btn' href='#{edit_order_path(@order)}'>
  #           #{t("order.modify")}
  #     </a> </div>)
  #    if @order.state_is?(["planner_approved","order_saved"])
  #     html << %Q( <div class="outer_submit" id="planner_hide">
  #          <input type="submit" class="submit_tag_button" name="commit" value='#{(@order.nonstandard_order? || @order.send_email_to_approve? ) ?  t("order.form.submit_approve1") : t("order.form.submit_approve1")}'">
  #     </div>)
  #    end
  #   end
  #   html << ele
  #   raw html
  # end

  def get_btn_html
    value = t("order.save")
    html = %Q( <div class="outer_submit">
            <input type="submit" value='#{value}' name="commit" class="submit_tag_button">
    </div> ) 
    html
  end

  def option_for_gp_advertisements(order,type = nil?)
    options=[]
    ad=order.map_gp_advertisements

    if order.any_not_order_gp_finish?
      options = [[t('order.form.allocated_all_products'),"all_config"]]
    else
      if ad.present?
        ad.each { |ad|
          options += [[ad.get_advertisements_live + I18n.locale.to_s == "en" ? (ad.product.en_name.present? ? ad.product.en_name : "") : ad.product.name,ad.id]]
        }
      end
    end
    options_for_select(options.sort_by{|i| i.first.strip}, type ? type : options[0])

  end

  def option_for_gp_region(city,current_city = nil)
    options=[]
    if city.present? && city !='-'
      city.each { |c|
        options += [[Order.map_region_names(c),c+"市"]]
      }
    end
    # end
    options_for_select(options.present? ?  options.sort_by{|i| i.first.strip} : [],(current_city ? [current_city+"市"] : options[0]) )

  end

  def option_for_gp_origin_size(origin_size,current_origin_size = nil)
    options=[]
    if origin_size.present?
      origin_size.each { |o|
        options += [[o]]
      }
    end
    options_for_select(options.sort_by{|i| i.first.strip},(current_origin_size ? current_origin_size : ""))
  end

  def option_for_gp_expand_size(expand_size,current_expand_size = nil)
    options=[]

    if expand_size.present?
      expand_size.each { |e|
        options += [[e]]
      }
    end
    # end

    options_for_select(options,(current_expand_size ? current_expand_size : ""))

  end

  def option_for_gp_media_type(media_type,current_media_type = nil)
    options=[]
    adsites = {"全部"=> t("order.form.all_adsites"), "NA" => "NA","新闻" => t('order.form.news_adsites'),"视频" => t("order.form.video_adsites"),"女性时尚" => t('order.form.beauty_adsites'),"门户" => t('order.form.portal_adsites'),"电商" => t('order.form.ecommercd_adsites'),"财经" => t('order.form.fiance_adsites'), "金融财经" => t('order.form.banking_adsites') }

    if media_type.present?
      media_type.each { |e|
        options += [[adsites[e],e]]
      }
    end
    options = [options[0]] + options[1..-1].sort_by{|i| i.first.strip}
    options_for_select(options,(current_media_type ? current_media_type : ""))

  end

  def option_for_sale_channel(sale_channel)
     options =[[t('order.form.please_select'),""],[t('order.form.direct_marketing'),"01"]]
     options_for_select(options,sale_channel.present? ? sale_channel : options[0])
  end

  def option_for_pay_condition(pay_condition)
     options = [["请选择",""],["立即全额付款","1001"],["30 天到期全额付款","1003"],["45 天到期全额付款","1004"],["60 天到期全额付款","1005"],["7 天到期全额付款","Z001"],["15 天到期全额付款","Z002"],["90 天到期全额付款","Z003"]]
     options_for_select(options,pay_condition.present? ? pay_condition : options[0])
  end

  def option_for_organize_number(organize_number)
    options =[["请选择",""]]
    options += Group.with_user(current_user).map{|g| [g.sap_group_id,g.sap_group_id]}
    options_for_select(options,organize_number.present? ? organize_number : options[0])
  end

  def option_for_sale_unit(sale_unit)
    options = [["请选择",""],["BJ - 內部公司 : iClick HK","11210901"],["BJ - 內部公司 : PMG HK","11210902"],["BJ - 內部公司 :  Tetris HK","11210903"],["BJ - 內部公司 :  CSA HK","11210904"],["BJ - 內部公司 :  搜索亞洲科技(深圳)有限公司","11210905"],["SH - 內部公司 : iClick HK","11310901"],["SH - 內部公司 : PMG HK","11310902"],["SH - 內部公司 : Tetris HK","11310903"],
               ["SH - 內部公司 :  CSA HK","11310904"],["SH - 內部公司 :  搜索亞洲科技(深圳)有限公司","11310905"],["BJ-技术部","112113"],["SH-技术部","113113"],["BJ-Direct sale（BJ）直客销售部-华北","11210501"],["BJ-Direct sale（SH）直客销售部-华东","11210502"],["BJ-Direct sale（GZ）直客销售部-华南","11210503"],["BJ-SEM sale（CN）搜索销售部","11210504"],
               ["BJ-Channel sale 渠道销售部","11210505"],["BJ-Sales Strategy Planning 销售策划部","11210506"],["BJ-Creative Design 创意设计部","11210507"],["BJ-Biz Operations - Search 业务运营","11210508"],["BJ-Biz Operations - Non Search  业务运营","11210509"],["BJ-Sales Operation 销售运营部","11210510"],["BJ-Int'l Biz & Access 海外客户运营部","11210511"],
               ["BJ-Media (Non- Search)","11210512"],["BJ-Media (Search)","112108"],["SH-Media (Search)","113108"],["SH-Direct sale（BJ）直客销售部-华北","11310501"],["SH-Direct sale（SH）直客销售部-华东","11310502"],["SH-Direct sale（GZ）直客销售部-华南","11310503"],["SH-SEM sale（CN）搜索销售部","11310504"],["SH-Channel sale 渠道销售部","11310505"],
               ["SH-Sales Strategy Planning 销售策划部","11310506"],["SH-Creative Design 创意设计部","11310507"],["SH-Biz Operations - Search 业务运营","11310508"],["SH-Int'l Biz & Access 海外客户运营部","11310510"],["SH-Sales Operation 销售运营部","11310511"],["SH-Media (Non- Search)","11310512"]
               ]

    options_for_select(options,sale_unit.present? ? sale_unit : options[0])

  end

  def option_for_client_invoice_type(client_invoice_type)
    options =[["请选择",""],["增值税专用发票","101"],["增值税普通发票","102"],["形式发票","103"]]
    options_for_select(options,client_invoice_type.present? ? client_invoice_type : options[0])
  end

  def option_for_product(product)
    options =[["请选择",""],["Net-媒体采购-搜索-移动端", "1"], ["Net-媒体采购-展示类-移动端", "2"], ["Net-媒体采购-视频类-移动端", "3"],
              ["Net-媒体采购-社交媒体/移动社交-移动端", "4"], ["Net-媒体采购-搜索-非移动端", "5"], ["Net-媒体采购-展示类-非移动端", "6"],
              ["Net-媒体采购-视频类-非移动端", "7"], ["Net-媒体采购-社交媒体/移动社交-非移动端", "8"], ["CPA-搜索-移动端", "9"],
              ["CPA-展示类-移动端", "10"], ["CPA-视频类-移动端", "11"], ["CPA-社交媒体/移动社交-移动端", "12"], ["CPA-搜索-非移动端", "13"],
              ["CPA-展示类-非移动端", "14"], ["CPA-视频类-非移动端", "15"], ["CPA-社交媒体/移动社交-非移动端", "16"], ["PMP-搜索-移动端", "17"],
              ["PMP-展示类-移动端", "18"], ["PMP-视频类-移动端", "19"], ["PMP-社交媒体/移动社交-移动端", "20"],
              ["PMP-搜索-非移动端", "21"], ["PMP-展示类-非移动端", "22"], ["PMP-视频类-非移动端", "23"], ["PMP-社交媒体/移动社交-非移动端", "24"],
              ["Net-纯技术服务-移动端", "25"], ["Net-纯技术服务-非移动端", "26"], ["后返虚拟产品", "27"],
              ["內部公司-Net-媒体采购-搜索-移动端", "28"], ["內部公司-Net-媒体采购-展示类-移动端", "29"],
              ["內部公司-Net-媒体采购-视频类-移动端", "30"], ["內部公司-Net-媒体采购-社交媒体/移动社交-移动端", "31"],
              ["內部公司-Net-媒体采购-搜索-非移动端", "32"], ["內部公司-Net-媒体采购-展示类-非移动端", "33"],
              ["內部公司-Net-媒体采购-视频类-非移动端", "34"], ["內部公司-Net-媒体采购-社交媒体/移动社交-非移动端", "35"],
              ["內部公司-CPA-搜索-移动端", "36"], ["內部公司-CPA-展示类-移动端", "37"], ["內部公司-CPA-视频类-移动端", "38"],
              ["內部公司-CPA-社交媒体/移动社交-移动端", "39"], ["內部公司-CPA-搜索-非移动端", "40"],
              ["內部公司-CPA-展示类-非移动端", "41"], ["內部公司-CPA-视频类-非移动端", "42"],
              ["內部公司-CPA-社交媒体/移动社交-非移动端", "43"], ["內部公司-PMP-搜索-移动端", "44"], ["內部公司-PMP-展示类-移动端", "45"],
              ["內部公司-PMP-视频类-移动端", "46"], ["內部公司-PMP-社交媒体/移动社交-移动端", "47"], ["內部公司-PMP-搜索-非移动端", "48"],
              ["內部公司-PMP-展示类-非移动端", "49"], ["內部公司-PMP-视频类-非移动端", "50"], ["內部公司-PMP-社交媒体/移动社交-非移动端", "51"],
              ["內部公司-Net-纯技术服务-移动端", "52"], ["內部公司-Net-纯技术服务-非移动端", "53"], ["內部公司-后返虚拟产品", "54"],
              ["智盒-展示类-移动端", "57"], ["內部公司-智盒–展示类-移动端", "58"]]
    options_for_select(options,product.present? ? product : options[0])

  end

  def option_for_order_product_type(product_type)
     options = [["请选择",""],["P4P搜索排名", "101"], ["P4P无线搜索", "102"], ["P4P网盟", "103"], ["P4P无线移动推广", "104"], ["N-P4P品牌专区", "105"],
                ["N-P4P黄金资源", "106"], ["N-P4P品牌地标", "107"], ["N-P4P移动应用推广", "108"], ["N-P4P鸿媒体", "109"],
                ["N-P4P数据产品", "110"], ["N-P4P轮播广告", "111"], ["N-P4P输入法", "112"], ["导航猜你喜欢", "113"], ["导航Hao123", "114"],
                ["广点通", "115"], ["DSP", "116"], ["富媒体", "117"], ["Display", "118"], ["视屏广告", "119"], ["XMOAdNetwork", "120"],
                ["微博", "121"], ["微信", "122"], ["QQ", "123"], ["SEO", "124"], ["doubleclick", "125"], ["其他", "126"]]
     # options = options.map{|x| [x[1].gsub(/\s+/,''),x[0].to_s]}
     options_for_select(options,product_type.present? ? product_type : options[0])

  end

  def option_for_project_task(project_task)

  end

  def get_client_share_sale(client_id)
    share_client = ShareClient.where({"client_id"=>client_id})
    if share_client.present?
    User.where({"id"=>share_client.map(&:share_id)}).pluck(:name).present? ? User.where({"id"=>share_client.map(&:share_id)}).pluck(:name).join(",") : ""
    else
      ""
    end
  end

  def option_for_order_status
    options = [[t("order.status.all_status"),""],[t("order.status.wait_submit"),t("order.status.wait_submit")],[t("order.status.pre_sale_check"),t("order.status.pre_sale_check")],
               [t("order.status.pre_sale_check_gp"),t("order.status.pre_sale_check_gp")],[t("order.status.pre_sale_check_gp_finish"),t("order.status.pre_sale_check_gp_finish")],[t("order.status.pre_sale_check_gp_checked"),t("order.status.pre_sale_check_gp_checked")],
               [t("order.status.pre_sale_unchecked"),t("order.status.pre_sale_unchecked")],
               [t("order.status.gp_in_check"),t("order.status.gp_in_check")],[t("order.status.gp_checked"),t("order.status.gp_checked")],
               [t("order.status.approving01"),t("order.status.approving01")],[t("order.status.approving02"),t("order.status.approving02")],[t("order.status.approved"),t("order.status.approved")],[t("order.status.unapproved"),t("order.status.unapproved")],
               [t("order.flow.schedule_list_submit"),t("order.flow.schedule_list_submit")],[t("order.status.contract_approving"),t("order.status.contract_approving")],
               [t("order.status.contract_approved"),t("order.status.contract_approved")],[t("order.status.contract_unapproved"),t("order.status.contract_unapproved")],[t("order.status.am_wait_distribute"),t("order.status.am_wait_distribute")],[t("order.status.am_distributed"),t("order.status.am_distributed")]]
   options_for_select(options)
  end

  def option_for_date
   last_week_date =  (Time.now - 7.days).strftime('%Y/%m/%d') +'-'+ Time.now.strftime('%Y/%m/%d')
   last_month_date = (Time.now - 1.months).strftime('%Y/%m/%d') +'-'+ Time.now.strftime('%Y/%m/%d')
   last_3month_date = (Time.now - 3.months).strftime('%Y/%m/%d') +'-'+ Time.now.strftime('%Y/%m/%d')
   options = [[t("order.last_week_date",last_week_date:last_week_date),"week"],[t("order.last_month_date",last_month_date:last_month_date),"1month"],
              [t("order.last_3month_date",last_3month_date:last_3month_date),"3month"],[t("order.all_date"),"all"]]
   options_for_select(options,'3month')
  end

  def option_for_share_ams(operators,last_operations)
    share_ams_selected = []
     if last_operations.present?
       share_ams = last_operations.share_ams
       share_ams_selected = share_ams.map(&:user_id)
     end
    options = operators.map{|o| [o.name+ "("+ o.agency.name+")",o.id]}
    options_for_select(options,share_ams_selected)
  end


end
