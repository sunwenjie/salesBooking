class UpdateBudgetRatioToAdvertisement < ActiveRecord::Migration
  def change
    Advertisement.where("budget_ratio <= 100").each{|ad|
      order = ad.order
        budget_ratio = (order && order.budget && ad.budget_ratio.present? ) ? order.budget.to_f * ad.budget_ratio("super").to_f / 100 : 0.0
        ad.update_columns({:budget_ratio => budget_ratio})
    }
  end
end
