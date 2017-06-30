class AddColumnOnMediaLists < ActiveRecord::Migration
  def change
    add_column :media_lists, :ad_format, :integer
    add_column :media_lists, :size, :string
    add_column :media_lists, :flow, :float
  end
end
