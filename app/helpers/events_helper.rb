module EventsHelper
  def options_for_event_group_list
    options = []
    select_list = @event.present? ? @event.group_ids : ""
    options += Group.where("status = ?","Active").order("group_name").pluck(:group_name,:id)
    options_for_select(options,select_list)
  end

  def options_for_event_user_list
    options = []
    select_list = @event.present? ? @event.user_ids : ""
    options += User.where("user_status = ?","Active").order("users.name").pluck(:name,:id)
    options_for_select(options,select_list)
  end
end
