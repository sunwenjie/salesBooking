class AddNameEnToInterestAudiences < ActiveRecord::Migration
  def change
    add_column :interest_audiences, :name_en, :string
  end
end
