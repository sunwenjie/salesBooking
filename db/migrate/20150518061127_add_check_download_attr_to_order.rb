class AddCheckDownloadAttrToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :check_download_attr, :string,:default =>{"impression"=>"true","ctr"=>"true","click"=>"true"}
  end
end
