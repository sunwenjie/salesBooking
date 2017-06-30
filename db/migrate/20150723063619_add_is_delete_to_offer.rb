class AddIsDeleteToOffer < ActiveRecord::Migration
  def change
    add_column :offers, :is_delete, :boolean,default: false
  end
end
