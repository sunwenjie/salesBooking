class AddFreeTagToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :free_tag, :string
    add_column :orders, :free_notice, :string
  end
end
