class ChannelWorker
  include Sidekiq::Worker

  def perform(client_id)
    client = Client.find(client_id)
    ClientMailer.notify_sale_with_client_same_channel(client).deliver
    ActiveRecord::Base.clear_active_connections!
  end

end