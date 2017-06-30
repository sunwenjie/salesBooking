class AddProductGpTypeToProducts < ActiveRecord::Migration
  def change
  	add_column :products, :product_gp_type, :string
  	add_column :products, :product_xmo_type, :string
  end
end
