class AddProductTypeCnToProducts < ActiveRecord::Migration
  def change
    add_column :products, :product_type_cn, :string
  end
end
