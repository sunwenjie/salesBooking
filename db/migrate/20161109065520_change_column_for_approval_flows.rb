class ChangeColumnForApprovalFlows < ActiveRecord::Migration
  def change
    rename_column :approval_flows,:operation_am_group,:coordinate_groups
  end
end
