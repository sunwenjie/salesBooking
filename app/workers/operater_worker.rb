class OperaterWorker
  include Sidekiq::Worker

  def perform(order_id, names=nil)
    order = Order.find(order_id)
    if names.nil?
      OrderMailer.notify_operaters_manager(order).deliver
    else
      OrderMailer.notify_operaters_member(order, names).deliver if names.length>0
    end
    ActiveRecord::Base.clear_active_connections!
  end

end 