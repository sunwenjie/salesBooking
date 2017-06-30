class Product < ActiveRecord::Base
  include SerialNumber

  has_many :advertisements,inverse_of: :product
  belongs_to :financial_settlement
  belongs_to :product_regional,inverse_of: :products
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
  validates :floor_discount, numericality: {greater_than: 0,less_than:100},presence: true
  validates :ctr_prediction, numericality: {greater_than: 0,less_than:100},presence: true
  validates :gp, numericality: {greater_than: 0,less_than:100},presence: true
  validates :currency, presence: true
  # validates_uniqueness_of :name ,:if => :many_bu?

  serialize :bu

  after_initialize :generate_product_serial

  # def self.gp_limit_ad
  #   Product.where(is_delete:false,is_distribute_gp:true)
  # end

  # def self.un_dsp_gp_limit_ad
  #   Product.where("is_delete = ? and is_distribute_gp and product_gp_type != ?",false,true,"dsp")
  # end

  private
  def generate_product_serial
    return unless new_record?
    self.product_serial = self.class.create_sn
  end

end
