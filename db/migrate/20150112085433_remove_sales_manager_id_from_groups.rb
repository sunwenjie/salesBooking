class RemoveSalesManagerIdFromGroups < ActiveRecord::Migration
  def change
    Group.all.each do |group|
      u = User.find(group.sales_manager_id)
      if u
        u.groups << group
        # u.save
      end
    end
    # remove_column :groups,:sales_manager_id
  end
end
