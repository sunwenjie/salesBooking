class AddAdmeasureToAdvertisements < ActiveRecord::Migration
  def change
    add_column :advertisements, :admeasure, :text
  end
end
