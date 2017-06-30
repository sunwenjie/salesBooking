class AddProductRegionalIdToProducts < ActiveRecord::Migration
  def change
    add_column :products, :product_regional_id, :integer
  end
end
