class AddOfferIdToAdvertisement < ActiveRecord::Migration
  def change
    add_column :advertisements, :offer_id, :integer
  end
end
