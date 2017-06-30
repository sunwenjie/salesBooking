class AddCitySizeToProvinces < ActiveRecord::Migration
  def change
    add_column :provinces, :city_size, :string
  end
end
