module ProductHelper
  def option_for_product_type(product_type)
    options = []
    options += ProductCategory.where("is_delete = ?", false).order("name").map { |category| [I18n.locale.to_s == "en" ? category.en_name : category.name, category.id] }
    options_for_select(options, product_type.present? ? product_type : "")
  end

  def option_for_bu(bu)
    options = [["iClick CN", "iClick CN"], ["iClick HK", "iClick HK"], ["OptAim", "OptAim"], ["Intl", "Intl"], ["CSA", "CSA"], ["PMG", "PMG"], ["iSG", "iSG"]]
    options_for_select(options, bu.present? ? bu.each { |x| x } : "")
  end

  def options_financial(locale)
    if locale == "en"
      FinancialSettlement.all.order(:name_en).collect { |fs| [fs.name_en, fs.id] }.unshift([t('products.new.please_select'), ''])
    else
      FinancialSettlement.all.order(:name_cn).collect { |fs| [fs.name_cn, fs.id] }.unshift([t('products.new.please_select'), ''])
    end
  end

  def options_for_regional(regional)
    options = []
    options += ProductRegional.where("is_delete = false").map { |regional| [I18n.locale.to_s == "en" ? regional.en_name : regional.name, regional.id] }
    options_for_select(options, regional)
  end

end
