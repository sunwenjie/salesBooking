class AddChannelIdToOrder < ActiveRecord::Migration
  def change
  	add_column :orders, :channel_id, :integer
  	Order.all.each do |order|
     order.channel_id = ( ( order.client && (order.client.channel == order.client.channel.to_i.to_s) ) ? order.client.channel.to_i : "" )
     order.save(:validate=>false)
  	end
  end
end
