module ClientsHelper

  def options_for_channels(client)
    sql = " SELECT DISTINCT channels.channel_name, channels.id, currencies.id currency_id,currencies.name as currency_name
              FROM channels
              left join xmo.currencies on channels.currency_id = currencies.id
              left join user_channels on channels.id = user_channels.channel_id
              WHERE (is_delete is null) "

    (current_user.administrator? || current_user.direct_sale?) ? sql : sql += " and user_channels.user_id = #{current_user.id}"

    if !@client.new_record?
      sql += " or channels.id = #{client.channel}" if (client.present? && client.channel.present?)
    end

    sql += " ORDER BY channel_name "
    all_agencys = Channel.find_by_sql(sql) || []
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
    options = [[t('clients.show.select_channel'), ""]]
    options += I18n.locale.to_s == 'en' ? Industry.find_by_sql(sql).map { |x| [x.name, x.id] } : Industry.find_by_sql(sql).map { |x| [x.name_cn, x.id] }

    options_for_select(options, selected)
  end

  def options_for_transfer
    selected = @client.user_id
    options = User.where.not(user_status: "Stopped").eager_load(:agency).order("binary trim(users.name)").map { |x| [x.name + " ("+(x.agency.name rescue '')+")", x.id] }
    options_for_select(options, selected)
  end


  def options_for_client_currency(current_currency_id)
    options = Currency.all.map { |c| [c.name, c.id] }
    options_for_select(options, current_currency_id.present? ? current_currency_id : 2)
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

  def show_share_to_group?
    @node_id && (@client.state=="unapproved" || @client.state == "approved" || @client.state=="cross_unapproved") && ((@node_id.split(",").include? "6") || (@node_id.split(",").include? "9") || current_user.administrator?)
  end

  def show_client_transfer?
    !@client.new_record? && (current_user.id == @client.user_id || current_user.administrator?)
  end

  def name_brand_error?
    @client.errors && @client.errors[:name_and_brand].present?
  end

  def name_brand_channel_error?
    @client.errors && @client.errors[:name_and_brand_channel].present?
  end

  def share_client_error?
    @client.errors && @client.errors[:share_client_blank].present?
  end

  def current_approval_client
    Client.with_sale_clients(current_user.id, @client.id).last || @client
  end

  def display_item(value)
  value.present? ? value : '-'
  end

end
