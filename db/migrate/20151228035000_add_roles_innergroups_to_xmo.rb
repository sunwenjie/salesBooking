class AddRolesInnergroupsToXmo < ActiveRecord::Migration
   def change
     # User.establish_connection "production".to_sym
     # User.all.each  do |u|
     #  roles = u.roles
     #  innergroups = u.innergroups
     #
     #  xmo_innergroups = {}
     #  innergroups.each { | k,v |
     #    group_ids = (v-[""]).map{|g| (Group.find g).xmo_group_id }
     #    xmo_innergroups[k] = group_ids
     #  }
     #
     #  p xmo_innergroups
     #
     #  xmo_user_id = u.xmo_user_id
     #  p u.id
     #  p u.xmo_user_id
     #  p "11111111111111111111111111111"
     #
     #  xmoUser = XmoUser.find (xmo_user_id)
     #  xmoUser.role_id = u.role_id
     #  xmoUser.roles = roles
     #  xmoUser.innergroups = xmo_innergroups
     #  xmoUser.save(:validate =>false)
    # end
  end
end
