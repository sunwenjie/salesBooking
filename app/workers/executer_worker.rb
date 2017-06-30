class ExecuterWorker
  include Sidekiq::Worker

  def perform(order_id)
    Order.find(order_id).generate_executer
  end

end