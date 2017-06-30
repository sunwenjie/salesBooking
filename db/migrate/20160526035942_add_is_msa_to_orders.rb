class AddIsMsaToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :whether_msa, :boolean,default: false
    add_column :orders, :whether_service, :boolean,default: false
    add_column :orders, :msa_contract, :string
    add_column :orders, :rebate, :decimal,precision: 6, scale: 3
  end
end
