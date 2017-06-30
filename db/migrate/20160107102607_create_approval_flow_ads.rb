class CreateApprovalFlowAds < ActiveRecord::Migration
  def change
    create_table :approval_flow_ads do |t|
      t.string :ad_type
      t.references :approval_flow, index: true

      t.timestamps
    end
  end
end
