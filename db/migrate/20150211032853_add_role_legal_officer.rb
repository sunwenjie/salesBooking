class AddRoleLegalOfficer < ActiveRecord::Migration
  def change
    legal_officer = Role.create(:name => "legal_officer")
  end
end
