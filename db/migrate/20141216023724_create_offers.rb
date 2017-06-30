class CreateOffers < ActiveRecord::Migration
  def change
    create_table :offers do |t|
      t.string :ad_platform
      t.string :ad_type
      t.string :regional
      t.decimal :public_price, precision: 6, scale: 2
      t.float :general_discount
      t.float :floor_discount
      t.float :ctr_prediction
      t.string :currency,:default => "RMB"
      t.timestamps
    end
  end
end
