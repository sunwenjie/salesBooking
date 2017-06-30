module AdminsHelper

  def options_for_channel_list
    options = []
    select_list = @user.present? ? @user.channel_ids : ""
    options += Channel.all.order("channel_name").pluck(:channel_name,:id)
    options_for_select(options,select_list)
  end

end
