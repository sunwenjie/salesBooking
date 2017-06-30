class CreateXmoClients < ActiveRecord::Migration
  def change
    create_table :xmo_clients do |t|
      t.string :name
    end
  end
end
