class BusinessOpportunityProduct < ActiveRecord::Base
  belongs_to :business_opportunity, inverse_of: :business_opportunity_products
  # soft deleted
  acts_as_paranoid
end
