class ClientWorker
  include Sidekiq::Worker

  def perform(client_id, examination_id, status, approval_groups, local_language, approver_id)
    client = Client.find client_id
    client.approver = approver_id
    examination = Examination.find(examination_id)
    if status != '1'
      ClientMailer.notify_client_approved(client, local_language).deliver
      if client.whether_cross_district? && client.state == 'cross_unapproved' && approval_groups.present? #给跨区审批人发邮件
        email = ClientMailer.notify_wait_client_examine(client, approval_groups, local_language, examination_id).deliver
        examination.update_column :message_id, email.message_id if email.present? && email.message_id.present?
      end
    else
      email = ClientMailer.notify_wait_client_examine(client, approval_groups, local_language, examination_id).deliver
      examination.update_column :message_id, email.message_id if email.present? && email.message_id.present?
    end
    ActiveRecord::Base.clear_active_connections!
  end
end