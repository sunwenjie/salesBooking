class AddEnProductTypeAndEnNameToProducts < ActiveRecord::Migration
  def change
    add_column :products, :product_type_en, :string
    add_column :products, :en_name, :string
  end
end
