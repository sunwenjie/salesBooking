class CopyRoleIdToRoles < ActiveRecord::Migration
  def change
  	@user = User.all
  	
  	@user.each do |f|
  		f.roles = [f.role_id.to_s]
  		f.save
  	end

    @user.each do |f|
      all_ad_attributes = {}
      f.roles.each do |r|
        role = Role.find(r.to_i).name
        all_ad_attributes["#{role}"] = f.group_ids.map{|group_id| group_id.to_s}
      end
    f.innergroups = all_ad_attributes
    f.save(:validate => false)
    end
    
  end
end
