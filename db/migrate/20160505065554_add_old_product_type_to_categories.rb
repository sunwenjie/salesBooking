class AddOldProductTypeToCategories < ActiveRecord::Migration
  def change
   products = Product.find_by_sql("select distinct products.product_type from products where products.product_type not in (select value from product_categories)")
   products.each do |product|
     product_cateroy = ProductCategory.new
     product_cateroy.name = product.product_type
     product_cateroy.en_name = product.product_type
     product_cateroy.value = product.product_type
     product_cateroy.is_delete = true
     product_cateroy.save
   end
   execute "update products inner join product_categories on products.product_type = product_categories.value set products.product_category_id = product_categories.id"
  end
end
