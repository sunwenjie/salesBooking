class CreateBusinessOpportunities < ActiveRecord::Migration
  def change
    create_table :business_opportunities do |t|
      t.integer :advertiser_id
      t.decimal :budget, precision: 11, scale: 2
      t.integer :currency_id
      t.string :deliver_start_date
      t.string :deliver_end_date
      t.integer :owner_sale
      t.string :cooperate_sales
      t.boolean :exist_msa,default: false
      t.boolean :exist_service,default:false
      t.integer :status,limit: 1
      t.integer :progress,limit:3
      t.text :remark

      t.timestamps
    end
  end
end
