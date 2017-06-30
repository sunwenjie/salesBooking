module ProductHelper
  def option_for_product_type(product_type)
    # options = [["PC-OTV(15s)", "PC-OTV(15s)"], ["PC-OTV(30s)", "PC-OTV(30s)"], ["Mofeeds", "Mofeeds"], ["PC-Richmedia", "PC-Richmedia"], ["PC-DSP", "PC-DSP"], ["Mobile-pre-roll", "Mobile-pre-roll"],
    #            ["Mofeeds+Banner混投", "Mofeeds+Banner混投"], ["MoSocial", "MoSocial"], ["Motv", "Motv"], ["Mobile-视频贴片", "Mobile-视频贴片"], ["Mobile-Banner", "Mobile-Banner"], ["OptAim-移动平台", "OptAim-移动平台"],
    #            ["OptAim-PC平台", "OptAim-PC平台"],["HK Media-Apple Daily","HK Media-Apple Daily"], ["HK Media-On.cc","HK Media-On.cc"], ["HK Media-Money 18","HK Media-Money 18"],
    #            ["HK Media-New Media Group","HK Media-New Media Group"]].sort_by{|i| i.first.strip}
    options = []
    options += ProductCategory.where("is_delete = ?",false).order("name").map{|category| [I18n.locale.to_s == "en" ? category.en_name : category.name ,category.id]}

    options_for_select(options,product_type.present? ? product_type: "")
  end

  def option_for_bu(bu)
    options = [["iClick CN", "iClick CN"],["iClick HK", "iClick HK"], ["OptAim", "OptAim"],["Intl","Intl"],["CSA","CSA"],["PMG","PMG"],["iSG","iSG"]]
    options_for_select(options,bu.present? ? bu.each { |x| x }:"")
  end

  def option_for_excute_team(excute_team)
    options = []
    select_list = excute_team.present? ? excute_team : ""
    options += Group.where("status = ?","Active").order("group_name").pluck(:group_name,:id)
    options_for_select(options,select_list)
  end

  def option_for_approval_team(approval_team)
    options = []
    select_list = approval_team.present? ? approval_team : ""
    options += Group.where("status = ?","Active").order("group_name").pluck(:group_name,:id)
    options_for_select(options,select_list)
  end

  def options_financial(locale)
    if locale == "en"
      FinancialSettlement.all.order(:name_en).collect{|fs| [fs.name_en, fs.id]}.unshift([t('products.new.please_select'),''])
    else
      FinancialSettlement.all.order(:name_cn).collect{|fs| [fs.name_cn, fs.id]}.unshift([t('products.new.please_select'),''])
    end
  end

  def options_for_regional(regional)
    options = []
    options +=  ProductRegional.where("is_delete = false").map{|regional| [I18n.locale.to_s == "en" ? regional.en_name : regional.name,regional.id]}
    options_for_select(options,regional)
  end

  def options_for_xmp_type(xmo_type)
    options = []
    options +=  PvDetail.find_by_sql("select distinct midia_form from pv_details").map{|product_type| [product_type.midia_form,product_type.midia_form]}
    options_for_select(options,xmo_type)
  end

end
