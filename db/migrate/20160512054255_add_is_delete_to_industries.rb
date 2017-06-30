class AddIsDeleteToIndustries < ActiveRecord::Migration
  def change
    add_column :industries, :code, :string
    add_column :industries, :is_delete, :boolean,:default => false
  end
end
