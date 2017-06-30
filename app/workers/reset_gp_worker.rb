class ResetGpWorker
  include Sidekiq::Worker

  def perform(order_id, gp_approval_groups, local_language)
    order = Order.find(order_id)
    email = OrderMailer.notify_gp_approval(order, gp_approval_groups, local_language).deliver
    ActiveRecord::Base.clear_active_connections!
  end

end 