class AddExcludeDateToOrder < ActiveRecord::Migration
  def change
     add_column :orders, :exclude_date, :string
  end
end
