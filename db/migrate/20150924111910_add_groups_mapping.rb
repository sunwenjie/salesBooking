class AddGroupsMapping < ActiveRecord::Migration
  def change
  	@groups = Group.all
    @groups.each do |group|
      group.select_users = group.user_ids
      group.save(:validate => false)
    end
  end
end
