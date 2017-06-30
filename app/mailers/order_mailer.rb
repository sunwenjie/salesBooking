class OrderMailer < BaseMailer

  attr_accessor :order,:user,:client

  def notify_wait_order_examine(order,approval_groups,node_status,node_id,local_language,examination_id,resend= nil)
    @order = order
    @user = order.user
    @client = order.client
    @local_language = local_language
    @node_id = node_id
    @examination_id = examination_id
    deliver_emails = User.where("id in (?) and user_status != 'Stopped'",Group.round_group_users(approval_groups.uniq)).map(&:useremail)
    # deliver_emails += ['wenjie.sun@i-click.com']
    unless deliver_emails.empty?
    if node_id == 5
    subject = local_language == "en" ? "[#{node_status[0]}] Order #{order.code}:  Waiting for your assignment  " : "[#{node_status[1]}] 订单 #{order.code}: 等待您的分配"
    elsif node_id == 7
    subject = local_language == "en" ? "[#{node_status[0]}] Order #{order.code}:  Waiting for gp estimation  " : "[#{node_status[1]}] 订单 #{order.code}: 等待毛利预估"
    else
    subject = local_language == "en" ? "[#{node_status[0]}] Order #{order.code}:  Waiting for your approval  " : "[#{node_status[1]}] 订单 #{order.code}: 等待您的审批"
    end
    subject =  "#{resend} #{subject}"
    mail(to: "#{deliver_emails.flatten.uniq.join(',')}", subject: subject)
    end
  end

  def notify_sale(order,node_status,status,local_language,other_useremail)
    @order = order
    @user = order.user
    @node_status = node_status
    @status = status.to_i
    @local_language = local_language
    @approver = order.approver.try(:name)
    subject = local_language == "en" ? "[#{node_status[0]}] Order #{order.code}: latest News": "[#{node_status[1]}] 订单 #{order.code}: 最新消息"

    emails = @user.user_status != "Stopped" ? [order.user.useremail] : []
    emails += other_useremail if other_useremail.present?
    share_user_email = User.where("id in (?) and user_status != 'Stopped'",order.share_order_user_ids).map(&:useremail)
    emails += share_user_email
    mail(to: "#{emails.uniq.join(',')}", subject: subject)
  end

  def notify_approver(order,email,node_id,language,body)
    nodes = [{1 =>["Pre-sales Approval","预审"]},{2 =>["Order Approval","审批"]},{3 =>["Non-standard Order Approval","特批"]},{4 =>["Contract Confirmation","合同确认"]},{5 =>["Operation Assignment","运营分配"]} ]
    node_status = node_id == 7 ?  ["GP Estimation","毛利预估"] : nodes[node_id-1][node_id]
    @order = order
    @local_language = language
    @body = body
    @user=order.user
    subject = language == "en" ? "[#{node_status[0]}] Order #{order.code}:  Approval Failed" : "[#{node_status[1]}] 订单 #{order.code}: 审批失败"
    mail(to: "#{email[0]}", subject: subject)
  end


  def notify_gp_approval(order,approval_groups,local_language)
    @order = order
    @local_language = local_language
    deliver_emails = User.where("id in (?) and user_status != 'Stopped'",Group.round_group_users(approval_groups.uniq)).map(&:useremail)

    subject = local_language == "en" ? "Order #{order.code} approval has been rejected, please check again the related gp values." : "订单 #{order.code}审批不通过，请审核相关节点之毛利值。"
    mail(to: "#{deliver_emails.flatten.uniq.join(',')}", subject: subject)

  end

end
