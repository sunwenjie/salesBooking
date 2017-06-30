class AddMediaToGps < ActiveRecord::Migration
  def change
    add_column :gps, :media, :string
    add_column :gps, :media_type, :string
    add_column :gps, :media_form, :string
    add_column :gps, :ad_original_size, :string
    add_column :gps, :ad_expand_size, :string
    add_column :gps, :ctr, :string
    add_column :gps, :average_cost_cpm, :float
    add_column :gps, :average_cost_cpc, :float
    add_column :gps, :save_flag, :boolean , :default => false
  end
end
