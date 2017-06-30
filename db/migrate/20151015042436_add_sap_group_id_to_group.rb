class AddSapGroupIdToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :sap_group_id, :string
  end
end
