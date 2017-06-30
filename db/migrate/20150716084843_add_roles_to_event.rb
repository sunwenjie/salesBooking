class AddRolesToEvent < ActiveRecord::Migration
  def change
    add_column :events, :roles, :string
  end
end
