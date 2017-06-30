class ChangeClientChannel < ActiveRecord::Migration
  def change
    Client.where("channel is not null and whether_channel = 1").each do |client|
      client_channel = Channel.find_by_channel_name(client.channel)
      client.channel = client_channel.id if client_channel
      client.save
    end
  end
end
