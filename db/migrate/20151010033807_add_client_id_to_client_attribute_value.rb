class AddClientIdToClientAttributeValue < ActiveRecord::Migration
  def change
    add_column :client_attribute_values, :client_id, :integer
  end
end
