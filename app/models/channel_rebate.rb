class ChannelRebate < ActiveRecord::Base
  belongs_to :channel, inverse_of: :channel_rebates

  def self.insert_channel_rebate(channel_id,all_nonuniforms_date_range,all_nonuniform_rebate)
    p all_nonuniforms_date_range
    p all_nonuniform_rebate
    all_nonuniforms_date_range.each do |d|
      order_nonuniform = ChannelRebate.new
      order_nonuniform.channel_id = channel_id
      order_nonuniform.start_date = d[1].split("~")[0]
      order_nonuniform.end_date = d[1].split("~")[1]
      order_nonuniform.rebate = all_nonuniform_rebate[d[0].gsub("_date_range","_rebate")].present? ? all_nonuniform_rebate[d[0].gsub("_date_range","_rebate")].gsub(',','') : nil
      order_nonuniform.save!
    end
  end
end
