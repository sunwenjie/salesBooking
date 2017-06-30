class CreateOperations < ActiveRecord::Migration
  def change
    create_table :operations do |t|
      t.string :action
      t.text :comment

      t.timestamps
    end
    add_reference :operations, :order, index: true
  end
end
