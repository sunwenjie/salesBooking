module ApprovalFlowsHelper

  def options_for_notes
    nodes = [[t('approval_flows.form.select_label'),""]]
    nodes += Node.all.order(:order_by).map{|m|[I18n.locale.to_s == "en" ? m.enname : m.name,m.id]}
  end

  def options_for_bu
    bu = [[t('approval_flows.form.select_label'),""]]
    bu +=  [["iClick CN", "iClick CN"],["iClick HK", "iClick HK"], ["OptAim", "OptAim"],["Intl","Intl"],["CSA","CSA"],["PMG","PMG"],["iSG","iSG"]]
    bu
  end

  def options_for_users
    xmo_groups
  end

  def options_for_products()
    products = [[I18n.locale.to_s == "en" ? "All" : "全部","ALL"]]
    list = Product.where("is_delete = ?",false).order("ad_platform","product_type").select{|m| m.bu.to_a.include? @approval_flow.bu}
    products += list.collect{|product| [I18n.locale.to_s == "en"  ? product.product_type_en : product.product_type_cn,product.product_type] }.uniq << [I18n.locale.to_s == "en" ? "OTHER" : "其他","OTHERTYPE"]

  end

  def options_for_approval_users
    xmo_groups
  end


  def xmo_groups
    groups = [[t('approval_flows.form.select_label'),""]]
    groups += Group.where({:status=> "Active"}).map{|m|[m.group_name,m.id]}.sort_by{|i| i.first.strip}
  end

  def options_for_range_type
    range_type = [[t('approval_flows.form.range_type'),'range'],['<=','<=']]
  end
end
