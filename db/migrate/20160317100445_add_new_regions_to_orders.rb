class AddNewRegionsToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :new_regions, :mediumtext
  end
end
