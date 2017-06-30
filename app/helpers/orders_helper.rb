module OrdersHelper


  def status_label(index, status, order)
    status.delete_at(7)
    is_jast_for_gp = order.is_jast_for_gp
    is_gp_finish = order.is_gp_commit
    map_state = ""
    map_order_flows = [
        {"0" => t("order.status.wait_submit"), "1" => [t("order.status.pre_sale_check"), t("order.status.pre_sale_check_gp"), t("order.status.pre_sale_check_gp_finish")], "2" => [t("order.status.pre_sale_checked"), t("order.status.pre_sale_finish_gp"), t("order.status.pre_sale_check_gp_checked")], "3" => t("order.status.pre_sale_unchecked")},
        {"1" => t("order.flow.gp_control_submit"), "2" => t("order.flow.unsupport_gp")},
        {"1" => t("order.status.approving01"), "2" => t("order.status.approved"), "3" => t("order.status.unapproved")},
        {"1" => t("order.status.approving02"), "2" => t("order.status.approved02"), "3" => t("order.status.unapproved02")},
        {"1" => t("order.flow.schedule_list_submit"), "2" => t("order.flow.schedule_list_unsubmit")},
        {"1" => t("order.status.contract_approving"), "2" => t("order.status.contract_approved"), "3" => t("order.status.contract_unapproved")},
        {"0" => t("order.status.am_wait_undistribute"), "1" => t("order.status.am_wait_distribute"), "2" => t("order.status.am_distributed")}]
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
          map_state = last_node_state(map_order_flows, status, index, is_jast_for_gp, is_gp_finish)
        else
          index = index - 1
          map_state = last_node_state(map_order_flows, status, index, is_jast_for_gp, is_gp_finish)
        end
      else
        map_state = map_order_flows[index][status[index]]
      end
    end
    return map_state
  end

  def last_node_state(map_order_flows, status, index, is_jast_for_gp, is_gp_finish)
    m = "0"
    j = 0
    flow_index = 0
    last_map_state = ""
    status[0..index].reverse.each_with_index do |s, i|
      m = s
      j = i
      flow_index = index - j
      break if s.to_i > 0 && !(flow_index == 1 && s == "2")
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
    return last_map_state
  end

  def order_approval_flow_status(status, index, is_non_standart)
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

  def color_class_for_distribute(operations, status)
    status = status.split(",")
    color_class = ""
    if operations.present? && status[-2] != "0"
      last_operations = operations.last
      if last_operations.action == "config_done"
        color_class = "status-ready"
      else
        color_class = "status-submit"
      end
    end
    return color_class
  end


  #加载订单用户对应BU产品
  def order_bu_product(actionname=nil, product_type=nil, product_id=nil)
    order_user = (@order && @order.id.present?) ? @order.user : current_user
    if %w(new edit update create).include? actionname
      products = order_user.send("self_bu_adcombo_new", product_type)
      products << [Product.find(product_id).name, product_id] if actionname != 'new' && product_id && Product.find(product_id).is_delete == true
      products
    else
      order_user.send("self_bu_adcombo_show", product_id)
    end

  end

  def options_for_ad_type(actionname, ad_type=nil, product = nil)
    order_user = (@order && @order.id.present?) ? @order.user : current_user
    if %w(new edit update create).include? actionname
      product_category = order_user.self_bu_adtype_new
      product_category << [I18n.locale.to_s == "en" ? product.product_type_en : product.product_type_cn, product.product_type] if product && product.is_delete == true
      product_category
    else
      [ad_type, ad_type]
    end
  end


  def option_for_order_status
    options = [[t("order.status.all_status"), ""], [t("order.status.wait_submit"), t("order.status.wait_submit")], [t("order.status.pre_sale_check"), t("order.status.pre_sale_check")],
               [t("order.status.pre_sale_check_gp"), t("order.status.pre_sale_check_gp")], [t("order.status.pre_sale_check_gp_finish"), t("order.status.pre_sale_check_gp_finish")], [t("order.status.pre_sale_check_gp_checked"), t("order.status.pre_sale_check_gp_checked")],
               [t("order.status.pre_sale_unchecked"), t("order.status.pre_sale_unchecked")],
               [t("order.status.gp_in_check"), t("order.status.gp_in_check")], [t("order.status.gp_checked"), t("order.status.gp_checked")],
               [t("order.status.approving01"), t("order.status.approving01")], [t("order.status.approving02"), t("order.status.approving02")], [t("order.status.approved"), t("order.status.approved")], [t("order.status.unapproved"), t("order.status.unapproved")],
               [t("order.flow.schedule_list_submit"), t("order.flow.schedule_list_submit")], [t("order.status.contract_approving"), t("order.status.contract_approving")],
               [t("order.status.contract_approved"), t("order.status.contract_approved")], [t("order.status.contract_unapproved"), t("order.status.contract_unapproved")], [t("order.status.am_wait_distribute"), t("order.status.am_wait_distribute")], [t("order.status.am_distributed"), t("order.status.am_distributed")]]
    options_for_select(options)
  end

  def option_for_date
    last_week_date = (Time.now - 7.days).strftime('%Y/%m/%d') +'-'+ Time.now.strftime('%Y/%m/%d')
    last_month_date = (Time.now - 1.months).strftime('%Y/%m/%d') +'-'+ Time.now.strftime('%Y/%m/%d')
    last_3month_date = (Time.now - 3.months).strftime('%Y/%m/%d') +'-'+ Time.now.strftime('%Y/%m/%d')
    options = [[t("order.last_week_date", last_week_date: last_week_date), "week"], [t("order.last_month_date", last_month_date: last_month_date), "1month"],
               [t("order.last_3month_date", last_3month_date: last_3month_date), "3month"], [t("order.all_date"), "all"]]
    options_for_select(options, '3month')
  end

  def option_for_share_ams(operators, last_operations)
    share_ams_selected = []
    if last_operations.present?
      share_ams = last_operations.share_ams
      share_ams_selected = share_ams.map(&:user_id)
    end
    options = operators.map { |o| [o.name+ "("+ o.agency.name+")", o.id] }
    options_for_select(options, share_ams_selected)
  end

  def have_base_action(action_name)
    return ["new", "edit", "create", "update"].include? action_name
  end

  def select_for_clients(action_name)
    if have_base_action(action_name) && current_user.manageable_clients.present?
      channel_all = Channel.all.map { |channel| [channel.id, channel.channel_name] }.to_h
      clients = current_user.manageable_clients.collect { |client|
        channel= client.channel? ? "#{t('order.list.channel')}:#{channel_all[client.channel]}"  : t('order.list.channel1')
        client_name = current_user.administrator? ? client.clientname : client.name
        ["#{client_name} | #{t('order.list.logo')}: #{client.brand} | #{channel}", client.id]
      }
    else
      channel_name = @order.client.try(:channel_name)
      client_name = @order.client.try(:clientname)
      brand_name = @order.client.try(:brand)
      channel=  channel_name ? "#{t('order.list.channel')}:#{channel_name}" : t('order.list.channel1')
      clients = @order.client ? [["#{client_name} | #{t('order.list.logo')}: #{brand_name} | #{channel}", @order.client_id]] : []
    end
    return clients
  end

  def options_by_order
    Operation.all.group_by(&:order_id)
  end

  def need_pre_check_orders
    Set.new(Order.orders_by_pre_check.map(&:id))
  end

  def gp_submint_orders
    Set.new(Examination.all_gp_submit)
  end

  def order_advertisements
    @order.advertisements.order(updated_at: :desc)
  end

  def order_approval_flow
    Order.with_current_order(current_user.id, @order.id).last
  end


end
