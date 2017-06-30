class AddWhetherNonuniformToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :whether_nonuniform, :boolean,default: true
    add_column :orders, :nonuniform_budget, :decimal,precision: 10, scale: 2
  end
end
