class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.string   :country_name
      t.string    :city_name
      t.integer    :criteria_id
      t.integer    :city_level
      t.string    :province_id
      t.timestamps
    end
  end
end
