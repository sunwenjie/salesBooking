class AddOrderIdToOrderAttributeValue < ActiveRecord::Migration
  def change
    add_column :order_attribute_values, :order_id, :integer
  end
end
