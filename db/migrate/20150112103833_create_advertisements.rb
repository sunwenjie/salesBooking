class CreateAdvertisements < ActiveRecord::Migration
  def change
    create_table :advertisements do |t|
      t.float :budget_ratio  
      t.string :ad_platform
      t.string :ad_type
      t.string :cost_type
      t.decimal :cost, precision: 6, scale: 2
      t.string :cost_currency
      t.float :discount
      t.text :price_presentation
      t.text :nonstandard_kpi
      t.timestamps
    end
    add_reference :advertisements, :order, index: true
    Order.all.each do |order|
      begin
        Advertisement.create({ 
          "order_id" => order.id,
          "budget_ratio" => 100,
          "ad_platform" => order.ad_platform,
          "ad_type" => order.ad_type,
          "cost_type" => order.cost_type,
          "cost" => order.cost,
          "cost_currency" => order.cost_currency,
          "discount" => order.discount,
          "price_presentation" => order.price_presentation,
          "nonstandard_kpi" => order.nonstandard_kpi
        }) 
      rescue
        p "order id #{order.id}"
        next
      end
    end
#      remove_column :orders,:ad_platform
#      remove_column :orders,:ad_type
#      remove_column :orders,:cost_type
#      remove_column :orders,:cost
#      remove_column :orders,:cost_currency
#      remove_column :orders,:discount
#      remove_column :orders,:price_presentation
#      remove_column :orders,:nonstandard_kpi

  end
end
