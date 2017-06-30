class AddAdPlatformToProducts < ActiveRecord::Migration
  def change
    add_column :products, :ad_platform, :string
  end
end
