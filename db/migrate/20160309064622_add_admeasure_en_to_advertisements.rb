class AddAdmeasureEnToAdvertisements < ActiveRecord::Migration
  def change
    add_column :advertisements, :admeasure_en, :text
  end
end
