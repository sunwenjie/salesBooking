class AddRangeTypeToApprovalFlows < ActiveRecord::Migration
  def change
    add_column :approval_flows, :range_type, :string
  end
end
