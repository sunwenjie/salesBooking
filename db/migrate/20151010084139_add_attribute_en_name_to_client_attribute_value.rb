class AddAttributeEnNameToClientAttributeValue < ActiveRecord::Migration
  def change
    add_column :client_attribute_values, :attribute_en_name, :string
  end
end
