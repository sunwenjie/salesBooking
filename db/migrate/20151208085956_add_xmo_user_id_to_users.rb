class AddXmoUserIdToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :xmo_user_id, :integer
  	add_column :groups, :xmo_group_id, :integer

    #1、booking同步user到xmo
  # 	User.all.each do |user|
  #     xmouser = XmoUser.find_by_username_and_user_status(user.username,"Active")
  #     if xmouser
  #       if user.roles & %w{8 9} == []
  #         xmouser.system_tag = 0
  #       else
  #         xmouser.system_tag = 1
  #       end
  #       xmouser.bu = (user.bu || [])
  #     else  
  #        p "1、booking同步user到xmo"
  #        xmouser = XmoUser.new
  #        xmouser.username = user.username
  #        xmouser.system_tag = 1
  #        xmouser.useremail = user.email
  #        xmouser.name = user.real_name
  #        xmouser.group_id = 0
  #        xmouser.salt = "10000"
  #        xmouser.password = Digest::SHA1.hexdigest("iclick888" + "wibble" + "10000")
  #        xmouser.user_status = (user.user_state == 'active' ? "Active" : "inactive" ) 
  #        xmouser.bu = (user.bu || [])
  #     end
  #     xmouser.save(:validate=>false)
  # 	end

  # 	#2、XMO同步user到booking
  # 	XmoUser.find_by_sql("select users.* from users left join groups on users.group_id = groups.id where users.id > 1217 and (group_type = 'Administrators' or group_type = 'Managers' or users.group_id = 0 )").each do |xmouser|
  #    bookinguser = User.find_by_username(xmouser.username)  
  # 	 if bookinguser
  #       bookinguser.xmo_user_id = xmouser.id
  # 	 else
  #       p "2222222222222-----XMO同步user到booking"
  #       if xmouser.useremail 
  #         bookinguser = User.new
  #         bookinguser.email = xmouser.useremail 
  #         bookinguser.password = "iclick888"
  #         bookinguser.username = xmouser.username
  #         bookinguser.real_name = xmouser.name
  #         bookinguser.innergroups = {}
  #         bookinguser.user_state = (xmouser.user_status == 'Active' ? "active" : "inactive" )
  #         bookinguser.role_id = 1
  #         bookinguser.roles = ["1"]
  #         bookinguser.is_active = 1
  #         bookinguser.bu = ["iClick CN"]
  #         bookinguser.xmo_user_id = xmouser.id  
  #       end
  # 	 end
  # 	    bookinguser.save(:validate=>false) 
  # 	end

  # 	#3、booking的groups同步到xmo；group_users映射到xmo
  #    @user_map_xmouser = {}
  #    User.all.each do |user|
  #     p "333333333333"
  #     @user_map_xmouser["#{user.id}"] = user.xmo_user_id.to_s
  #    end 

  #   def map_xmo_user(arr)
  #     xmo_user_ids = []
  #     arr.each do |a|
  #        xmo_user_ids << @user_map_xmouser[a]
  #     end
  #     xmo_user_ids
  #   end

  # 	Group.where("id > 2 ").each do |group|
  #     p "3、booking的groups同步到xmo；group_users映射到xmo"
  #     xmogroup = XmoGroup.new
  #     xmogroup.group_name = group.name
  #     xmogroup.group_type = "Managers"
  #     xmogroup.status = "Active"
  #     xmogroup.select_users = map_xmo_user(group.select_users || [])
  #     xmogroup.save(:validate=>false)
      
  #     group.user_ids.each do |user_id|
  #       p "group_user ***********************" 
  #       if user_id && user_id.to_i>0 && @user_map_xmouser[user_id.to_s] && @user_map_xmouser[user_id.to_s].to_i > 0
  #         XmoGroup.connection.insert("insert into xmo.users_groups (user_id,group_id) values (#{@user_map_xmouser[user_id.to_s]},#{xmogroup.id})")
  #       end
  #     end

  #     group.xmo_group_id = xmogroup.id
  #     group.save(:validate=>false)
  # 	end

  # #4、同步子组到xmo 
  #    @group_map_xmogroup = {}
  #    Group.all.each do |group|
  #     p "444444444"
  #     @group_map_xmogroup["#{group.id}"] = group.xmo_group_id.to_s
  #    end 
    
  #   def map_xmo_group(arr)
  #     xmo_childrengroups = []
  #     arr.each do |a|
  #        xmo_childrengroups << @group_map_xmogroup[a]
  #     end
  #     xmo_childrengroups
  #   end

  #   Group.all.each do |group|
  #     p "4、同步子组到xmo"
  #     xmogroup = XmoGroup.find(group.xmo_group_id.to_i)
  #     xmogroup.childrengroups = map_xmo_group(group.childrengroups || [])
  #     xmogroup.save
  #   end

  #   #5、XMO新同步到用户的组同步
  #   XmoUser.where("group_id = 0").each do |xmouser|
  #     p "5、新同步到用户的组同步"
  #     user_group = XmoGroup.connection.select_all("select * from xmo.users_groups where user_id = #{xmouser.id} ")
  #     p user_group[0]["group_id"] if user_group && user_group[0]
  #     if user_group && user_group[0] && user_group[0]["group_id"] > 0
  #       xmouser.group_id = user_group[0]["group_id"].to_i
  #       xmouser.save
  #     end
  #   end

  end
end
