class Addnonstandardkpitoorders < ActiveRecord::Migration
  def change
     add_column :orders, :nonstandard_kpi, :text
  end
end
