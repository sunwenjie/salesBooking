class AddUnstandardApproveToApprovalFlows < ActiveRecord::Migration
  def change
    add_column :approval_flows, :unstandard_approve, :integer
  end
end
