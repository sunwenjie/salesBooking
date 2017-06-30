module ApplicationHelper
  include SendMenu
  include ActionView::Helpers::NumberHelper

  def add_link
    link = nil
    result = ""
    link = if action_name == "index" && controller_name != "admins"
             "<a href=#{url_for(controller: controller_name, action: 'new')}><i class='plus-ico'></i><span>#{I18n.t("#{controller_name}.title")}</span></a>"
           else
             nil
           end
    result << "<div class='row' >"
    result << "<div class='pull-left plus-button' style='margin-left:0px;'>#{link}</div>" if link
    result << "<div class='row'><div class='pull-right' style='padding-top:12px'><a href='javaScript:void(0)' style='text-decoration: underline' class ='order_href'><i class='icon-download'></i>#{t('order.list.download_order_list')}</a></div></div>" if controller_name == 'orders' && action_name == 'index'
    result << "<div class='row'><div class='pull-right' style='padding-top:12px'><a href='javaScript:void(0)' style='text-decoration: underline' class = 'client_href'><i class='icon-download'></i>#{t('clients.index.download_clients')}</a></div></div>" if controller_name == 'clients' && action_name == 'index'
    result << "<div class='row'><div class='pull-right' style='padding-top:12px'><a href=#{download_products_url} style='text-decoration: underline'><i class='icon-download'></i>#{t('products.index.download_products')}</a></div></div>" if controller_name == 'products' && action_name == 'index'
    result << "<div class='row'><div class='pull-right' style='padding-top:12px'><a href=#{download_channels_url} style='text-decoration: underline'><i class='icon-download'></i>#{t('products.index.download_agencies')}</a></div></div>" if controller_name == 'channels' && action_name == 'index'
    result << "<div class='row'><div class='pull-right' style='padding-top:12px'><a href=#{download_approval_flows_url} style='text-decoration: underline'><i class='icon-download'></i>#{t('approval_flows.index.download_approval_flows')}</a></div></div>" if current_user.administrator? && controller_name == 'approval_flows' && action_name == 'index'

    result << "</div>"
    result
  end

  def page_title_1
    unless action_name == "welcome"
      "<div class='client-row'><span class='content_name_12'>#{back_link}#{I18n.t("#{controller_name}.#{action_name}_pt")}</span></div>"
    else
      ""
    end
  end

  def page_title_2
    unless action_name == "welcome"
      "<div class='row'><div class='client-row'><h1>#{I18n.t("#{controller_name}.#{action_name}_pt")}</h1></div></div>"
    else
      ""
    end
  end

  def back_link
    back_link = is_platform_setting? ? "<a href=#{url_for(controller: 'products', action: 'index')}>#{I18n.t("platform_setting")}</a>" + " > " : ""
    unless ["index", "preview_interest", "preview_website"].include?(action_name)
      back_link += "<a href=#{url_for(controller: controller_name, action: 'index')}>#{I18n.t("#{controller_name}.index_pt")}</a>" + " > "
    end
    back_link
  end

  def is_platform_setting?
    ["products", "channels", "approval_flows", "admins", "groups"].include?(controller_name)
  end


  def options_for_share_sale(me_name,action_name)
    options = []
    select_list = @share_order ? @share_order : instance_variable_get("@share_sales_#{me_name}_ids")
    object_type = me_name == 'order' ? @order : @client
    create_user_bu = object_type.new_record? ? current_user.bu : User.find(object_type.user_id).bu
    bu = create_user_bu.present? ? create_user_bu.first : ''
    options += User.where("bu like '%#{bu}%'").where.not(user_status: "Stopped").eager_load(:agency).order("binary trim(users.name)").map { |x| [x.name+" ("+(x.agency.name rescue '')+")", x.id] }

    if (me_name == 'order' && !@order.new_record? && action_name != 'edit') || (me_name == 'client' && !@client.new_record? && action_name != 'edit')
      share_user = User.where(User.user_conditions(select_list)).eager_load(:agency).map { |x| [x.name + " ("+(x.agency.name rescue '')+")", x.id] }
      options += share_user
    end
    options_for_select(options.uniq.sort_by { |i| i.first.strip }, select_list)
  end

  def options_for_order_group(user_ids, group_ids)
    options = []
    user_group_ids = User.where({id: user_ids}).map { |user| user.groups.pluck(:id) }.flatten.uniq
    options += Group.where('status = ? and id in (?)', 'Active', user_group_ids).pluck(:group_name, :id)
    options_for_select(options.sort_by { |i| i.first.strip }, group_ids)
  end


  def new_link
    link = nil
    result = ""
    link = if @users
             link_to "新增用户", new_user_registration_path
           else
             ""
           end
    result << "<div class='row'><div class='pull-left header_add_new_link'>#{link}</div></div>" if link
    result
  end

  def controller_name
    controller.controller_name
  end

  def action_name
    controller.action_name
  end

  def li_class(current_action=[])
    current_action.include?(controller_name) ? "selected" : ""
  end

  def option_for_currency(current_currency)
    options = Currency.all.map { |c| [c.name, c.name] }
    options_for_select(options, current_currency.present? ? current_currency : "RMB")
  end

  def currency_sign(currency_name)
    map = {"HKD" => "HK$", "RMB" => "¥", "USD" => "$", "SGD" => "S$", "TWD" => "NT$", "KRW" => "₩", "JPY" => "J¥", "MYR" => "RM", "GBP" => "￡", "EUR" => "€", "AUD" => "A$", "THB" => "฿", "RUB" => "руб", "IDR" => "Rp"}
    map[currency_name.to_s] || ''
  end

end
