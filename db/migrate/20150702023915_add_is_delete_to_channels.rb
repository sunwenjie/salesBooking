class AddIsDeleteToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :is_delete, :string
  end
end
