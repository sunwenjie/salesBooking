class AddRoleIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :role_id, :integer
    add_index :users,:role_id
    User.all.each do |user|
      role = Role.find_by(:name => user.read_attribute(:role))
      if role
        user.role_id = role.id
        user.save
      end
    end
    # remove_column :users,:role
  end
end
