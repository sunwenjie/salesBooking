class AddIsDistributeGpToProducts < ActiveRecord::Migration
  def change
    add_column :products, :is_distribute_gp, :boolean
  end
end
