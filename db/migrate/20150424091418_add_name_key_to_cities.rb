class AddNameKeyToCities < ActiveRecord::Migration
  def change
    add_column :cities, :name, :string
    add_column :cities, :name_key, :string
  end
end
