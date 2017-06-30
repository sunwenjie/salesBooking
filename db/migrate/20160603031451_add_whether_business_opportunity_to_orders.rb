class AddWhetherBusinessOpportunityToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :whether_business_opportunity, :boolean,default: false
    add_column :orders, :business_opportunity_number, :string
  end
end
