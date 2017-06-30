class AddXmoUserIdToUserChannels < ActiveRecord::Migration
  def change
    User.establish_connection "production".to_sym
    Group.establish_connection "production".to_sym

    Product.all.each do |p|
      approval_team =  p.approval_team
      executive_team = p.executive_team
      approval_team_xmo = (Group.find approval_team).xmo_group_id
      executive_team_xmo = (Group.find executive_team).xmo_group_id

      p "**********approval_team_xmo:#{approval_team_xmo},executive_team_xmo:#{executive_team_xmo}"
      p.save(:validate => false)
    end

    # user_id
    orders = Order.find_by_sql("select * from orders")
    orders.each do |o|
      userid = o.user_id
      xmo_user_id = (User.find userid).xmo_user_id
      o.user_id = xmo_user_id
      p "**********user_id:#{xmo_user_id}"
      o.save(:validate => false)
    end

    execute "update user_channels  inner join users  on user_channels.user_id = users.id set user_id = users.xmo_user_id";

    execute "update client_groups  inner join groups  on client_groups.group_id = groups.id set group_id = groups.xmo_group_id";

  end
end
