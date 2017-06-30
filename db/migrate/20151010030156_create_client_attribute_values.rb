class CreateClientAttributeValues < ActiveRecord::Migration
  def change
    create_table :client_attribute_values do |t|
      t.integer :attribute_id
      t.string :value
      t.string :system

      t.timestamps
    end
  end
end
