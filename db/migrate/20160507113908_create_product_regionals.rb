class CreateProductRegionals < ActiveRecord::Migration
  def change
    create_table :product_regionals do |t|
      t.string :name
      t.string :en_name
      t.string :value
      t.boolean :is_delete,:default => false
      t.timestamps
    end
  end
end
