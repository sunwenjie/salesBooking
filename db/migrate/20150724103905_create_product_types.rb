class CreateProductTypes < ActiveRecord::Migration
  def change
    create_table :product_types do |t|
      t.string :name
      t.string :ad_platform
      t.string :ad_type

      t.timestamps
    end
  end
end
