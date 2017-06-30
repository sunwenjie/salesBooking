class UpdateShareIdMigration < ActiveRecord::Migration
  def change
   ApprovalFlow.all.each{|flow|
   flow.add_ads_item
   }
  end
end
