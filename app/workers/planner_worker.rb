class PlannerWorker
  include Sidekiq::Worker

  def perform(order_id, planners, examination_id, node_status, local_language, resend = nil)
    order = Order.find(order_id)
    examination = Examination.find(examination_id)
    email = OrderMailer.notify_wait_order_examine(order, [], node_status, 1, local_language, examination_id, resend, planners).deliver
    examination.update_column :message_id, email.message_id if email.present?
    ActiveRecord::Base.clear_active_connections!
  end

end