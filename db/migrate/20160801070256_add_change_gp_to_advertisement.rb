class AddChangeGpToAdvertisement < ActiveRecord::Migration
  def change
    add_column :advertisements, :change_gp, :decimal,precision: 6, scale: 2
  end
end
