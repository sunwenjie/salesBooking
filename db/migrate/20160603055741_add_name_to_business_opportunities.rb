class AddNameToBusinessOpportunities < ActiveRecord::Migration
  def change
    add_column :business_opportunities, :name, :string
    add_column :business_opportunities, :created_by, :integer
  end
end
