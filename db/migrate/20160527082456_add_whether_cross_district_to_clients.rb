class AddWhetherCrossDistrictToClients < ActiveRecord::Migration
  def change
    add_column :clients, :whether_cross_district, :boolean,default: false
  end
end
