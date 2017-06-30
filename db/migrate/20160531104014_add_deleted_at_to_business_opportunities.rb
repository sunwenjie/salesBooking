class AddDeletedAtToBusinessOpportunities < ActiveRecord::Migration
  def change
    add_column :business_opportunities, :deleted_at, :date
    add_column :business_opportunity_products, :deleted_at, :date
  end
end
