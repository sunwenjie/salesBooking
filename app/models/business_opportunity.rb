class BusinessOpportunity < ActiveRecord::Base
  has_many :business_opportunity_products,inverse_of: :business_opportunity
  has_many :business_opportunity_orders,inverse_of: :business_opportunity
end
