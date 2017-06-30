class AddAttributeEnNameToOrderAttributeValue < ActiveRecord::Migration
  def change
    add_column :order_attribute_values, :attribute_en_name, :string
  end
end
