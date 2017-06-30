class AddDeletedAtToOffers < ActiveRecord::Migration
  def change
    add_column :offers, :deleted_at, :datetime
  end
end
