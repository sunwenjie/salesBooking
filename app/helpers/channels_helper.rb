module ChannelsHelper

  def options_for_channel_users(channel)
    options = []
    select_list = channel.users.map(&:id) || ''
    options += User.where("user_status != ?","Stopped").eager_load(:agency).order("binary trim(users.name)").map{|x| [x.name+" ("+(x.agency.name rescue '')+")",x.id]}
    options_for_select(options.sort_by{|i| i.first.strip},select_list)
  end

  def options_for_currency(current_currency_id)
    options = Currency.all.map{|c| [c.name,c.id]}
    options_for_select(options,current_currency_id.present? ? current_currency_id : 2)
  end

end
