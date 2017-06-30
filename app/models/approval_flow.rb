class ApprovalFlow < ActiveRecord::Base

  belongs_to :node

  has_many :approval_flow_ads, dependent: :delete_all

  has_many :permissions, dependent: :delete_all

  serialize :product_type

  serialize :coordinate_groups

  validates :coordinate_groups, presence: true, if: -> {self.node_id == 5 or self.node_id == 1}

  validates :name, presence: true, uniqueness: true

  validates :node_id, presence: true

  validates :user_group, presence: true

  validates :approval_group, presence: true

  validates :min, presence: true, if: -> { self.node_id == 3 }

  validates :max, presence: true, if: -> { self.node_id == 3 }

  belongs_to :group, foreign_key: 'user_group'

  after_save :add_ads_item

  def p_coordinate_groups
    self.coordinate_groups
  end

  def p_coordinate_groups= (p_groups)
    self.coordinate_groups = p_groups if self.node_id == 1
  end

  def approver_group
    Group.find(self.approval_group.to_i)
  end

  def add_ads_item
    if self.product_type.present?
      ids = ApprovalFlowAd.where(:approval_flow_id => self.id).map(&:id)
      ApprovalFlowAd.destroy(ids) if ids.present?
      self.product_type.each do |ad|
        ad = "ALL" if ad.blank?
        ApprovalFlowAd.create({ad_type: ad, approval_flow_id: self.id})
      end
    end
    Permission.group_cartesian_product(self)
  end

end
