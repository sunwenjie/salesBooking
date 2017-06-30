class CreateClientInstruties < ActiveRecord::Migration
  def change
    create_table :client_instruties do |t|
      t.integer :client_id
      t.string :client_name
      t.string :brand
      t.string :agency
      t.string :share_sale
      t.string :instruty
      t.string :remark

      t.timestamps
    end
  end
end
