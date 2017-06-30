class AddRoleSuperUser < ActiveRecord::Migration
  def change
    legal_officer = Role.create(:name => "super_user")
  end
end
