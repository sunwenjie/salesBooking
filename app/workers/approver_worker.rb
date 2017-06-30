class ApproverWorker
  include Sidekiq::Worker

  def perform(order_or_client_id, email, node_id, language, type="Order", body=nil)
    if type == 'Order'
      order = Order.find(order_or_client_id)
      OrderMailer.notify_approver(order, email, node_id, language, body).deliver
    else
      client = Client.find(order_or_client_id)
      ClientMailer.notify_approver(client, email, language, body).deliver
    end
    ActiveRecord::Base.clear_active_connections!
  end


end