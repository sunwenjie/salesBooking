class BusinessOpportunityProduct < ActiveRecord::Base
  belongs_to :business_opportunity, inverse_of: :business_opportunity_products
  belongs_to :product, inverse_of: :business_opportunity_products
  # soft deleted
  acts_as_paranoid


  def self.update_product_id(product_ori, product_new)
    where({product_id: product_ori.id}).update_all(product_id: product_new.id)
  end

end
