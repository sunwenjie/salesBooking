class AddGpToProducts < ActiveRecord::Migration
  def change
    add_column :products, :gp, :decimal,precision: 18, scale: 2
  end
end
