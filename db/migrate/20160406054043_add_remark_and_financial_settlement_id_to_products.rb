class AddRemarkAndFinancialSettlementIdToProducts < ActiveRecord::Migration
  def change
    add_column :products, :financial_settlement_id, :integer
    add_column :products, :remark, :text
  end
end
