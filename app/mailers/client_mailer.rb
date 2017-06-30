#encoding: utf-8
class ClientMailer < BaseMailer

  def notify_wait_client_examine(client,approval_groups,local_language,examination_id)
    @client = client
    @local_language = local_language
    @examination_id = examination_id
    subject = local_language == "en" ? "[Advertiser Approval] Advertiser #{client.code}: Waiting for your approval" : "[广告主审批] 广告主 #{client.code}:等待您的审批"
    deliver_emails = User.where("id in (?) and user_status != 'Stopped'",Group.round_group_users(approval_groups.flatten)).map(&:useremail)
    # deliver_emails = ["734961281@qq.com"]
    unless deliver_emails.empty?
      mail(to: "#{deliver_emails.flatten.uniq.join(',')}", subject: subject)
    end
  end

  def notify_client_approved(client,local_language)
    client_state = {"approved"=> client.whether_cross_district? ? ["跨区特批已通过","跨区特批已通过"] : ["Approved","审批已通过"],
                    "cross_unapproved" => ["Approved","审批已通过"],
                    "cli_rejected"=>["Rejected","审批未通过"],
                    "released"=>["Released","权限已释放"]}
    subject = local_language == "en" ? "[Advertiser Approval] Advertiser #{client.code}: Latest News" : "[广告主审批] 广告主 #{client.code}:最新消息"

    @client = client
    @status = client_state[client.state]
    @local_language = local_language
    @approver = client.approver.try(:name)
    email =  [client.user.useremail]
    share_user_email = User.where("id in (?) and user_status !='Stopped' ",client.share_client_user_ids).map(&:useremail)
    email += share_user_email

    # email = "wenjie.sun@i-click.com"
    mail(to: email.uniq.join(','), subject: subject) if client.user.user_status != "Stopped"
  end

  def notify_client_share_or_released(client)
    @client = client
    if client.lock_records && client.lock_records[1]
      share_emails = [client.lock_records[1].user.useremail]
      share_emails << client.user.useremail
      mail(to: "#{share_emails.flatten.uniq.join(',')}", subject: t("order.form.booking_system_status_changed",client_name: "#{@client.clientname}"))
    end
  end

  def notify_client_released(client,time = nil)
    @client = client
    @time = time
    if @time
      mail(to: "#{client.user.useremail}", subject: t("order.form.booking_system_released1",client_name: "#{@client.clientname}"))
    else
      mail(to: "#{client.user.useremail}", subject: t("order.form.booking_system_released2",client_name: "#{@client.clientname}"))
    end
  end

  def notify_approver(client,email,language,body)
    @client = client
    @local_language = language
    @body = body
    subject = language == "en" ? "[Advertiser Approval] Advertiser #{client.code}: Approval Failed" : "[广告主审批] 广告主 #{client.code}:审批失败"

    mail(to: "#{email[0]}", subject: subject)
  end

end