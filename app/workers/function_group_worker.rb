class FunctionGroupWorker
  include Sidekiq::Worker

  def perform(order_id)
    order = Order.find(order_id)
    OrderMailer.notify_function_group(order).deliver
    ActiveRecord::Base.clear_active_connections!
  end

end