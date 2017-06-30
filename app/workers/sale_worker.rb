class SaleWorker
  include Sidekiq::Worker

  def perform(order_id,node_status,status,local_language,other_useremail,approver_id)
    order = Order.find(order_id)
    order.approver = approver_id.to_i
    OrderMailer.notify_sale(order,node_status,status,local_language,other_useremail).deliver
    ActiveRecord::Base.clear_active_connections!
  end

end