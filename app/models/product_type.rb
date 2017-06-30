class ProductType < ActiveRecord::Base
  # has_many :offers,inverse_of: :product_type
  validates :name,:ad_type,:presence => true
  validates_uniqueness_of :name,:ad_type
end
