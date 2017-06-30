class AddCityToGps < ActiveRecord::Migration
  def change
    add_column :gps, :city, :string
  end
end
