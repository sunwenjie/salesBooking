class AddBuToUsers < ActiveRecord::Migration
  def change
    add_column :users, :bu, :string
  end
end
