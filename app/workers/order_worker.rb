class OrderWorker
  include Sidekiq::Worker

  def perform(order_id, approval_groups, examination_id, node_status, node_id, local_language, resend = nil)
    order = Order.find(order_id)
    examination = Examination.find(examination_id)
    email = OrderMailer.notify_wait_order_examine(order, approval_groups, node_status, node_id, local_language, examination_id, resend).deliver
    examination.update_column :message_id, email.message_id if email.present?
    ActiveRecord::Base.clear_active_connections!
  end

end