class ProductRegional < ActiveRecord::Base
  has_many :products,inverse_of: :product_regional
end
