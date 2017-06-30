module GroupsHelper
  
  def options_for_childrengroups_list
    options = []
    select_list = @group.present? ? @group.childrengroups : ""
    options += Group.where("status = ?","Active").order("group_name").pluck(:group_name,:id)
    options_for_select(options,select_list)
  end

  def options_for_except_groups_list
    options = []
    select_list = @group.present? ? @group.except_groups : ""
    options += Group.where("status = ?","Active").order("group_name").pluck(:group_name,:id)
    options_for_select(options,select_list)
  end

  def options_for_select_users_list
    options = []
    select_list = @group.present? ? @group.select_users : ""
    options += User.where("user_status = ?","Active").order("name").pluck(:name,:id)
    options_for_select(options,select_list)
  end

  def options_for_except_users_list
    options = []
    select_list = @group.present? ? @group.except_users : ""
    options += User.where("user_status = ?","Active").order("name").pluck(:name,:id)
    options_for_select(options,select_list)
  end

end
