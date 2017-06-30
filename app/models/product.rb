class Product < ActiveRecord::Base
  include Concerns::SerialNumber

  has_many :advertisements, inverse_of: :product
  has_many :business_opportunity_products, inverse_of: :product
  belongs_to :financial_settlement
  belongs_to :product_regional, inverse_of: :products
  belongs_to :product_category
  validates :product_serial, presence: true
  validates :name, presence: true
  #validates :single_buy_amount, presence: true
  #validates :actual_accord_lowest_buy_amount, presence: true
  validates :public_price, presence: true
  # validates :approval_team, presence: true
  # validates :executive_team, presence: true
  validates :bu, presence: true
  #validates :general_discount, numericality: {greater_than: 0,less_than:1},presence: true
  validates :floor_discount, numericality: {greater_than: 0, less_than: 100}, presence: true
  validates :ctr_prediction, numericality: {greater_than: 0, less_than: 100}, presence: true
  validates :gp, numericality: {greater_than: 0, less_than: 100}, presence: true
  validates :currency, presence: true
  # validates_uniqueness_of :name ,:if => :many_bu?

  serialize :bu

  after_initialize :generate_product_serial

  def self.bu_product(bu)
    where({is_delete: false}).order('ad_platform', 'product_type').select { |product| product.bu.to_a.include? bu }
  end


  def self.new_product(params)
    product = Product.new(params[:product])
    product_category = product.product_category
    product.product_type = product_category.value
    product.product_type_cn = product_category.name
    product.product_type_en = product_category.en_name
    product.floor_discount = params[:product][:floor_discount].present? ? params[:product][:floor_discount].to_f / 100 : nil
    return product
  end


  private
  def generate_product_serial
    return unless new_record?
    self.product_serial = self.class.create_sn
  end

end
