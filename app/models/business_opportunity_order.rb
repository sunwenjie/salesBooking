class BusinessOpportunityOrder < ActiveRecord::Base
  belongs_to :business_opportunity,inverse_of: :business_opportunity_orders
  belongs_to :order,inverse_of: :business_opportunity_orders
end
