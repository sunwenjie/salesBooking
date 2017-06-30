class Examination < Base

  belongs_to :examinable, polymorphic: true

  belongs_to :order,inverse_of: :examinations,foreign_key: "examinable_id",touch:true

  belongs_to :client,inverse_of: :examinations,foreign_key: "examinable_id",touch:true

  validates :created_user, presence: true

  validates :approval, presence: true

  serialize :comment

  after_save :update_order_last_user

  def update_order_last_user
    if self.examinable_type == 'Order' && self.examinable_id.present?
      Order.find(self.examinable_id).update_last_user_and_last_time(self.created_user) if Order.find_by_id(self.examinable_id).present?
    end
  end

end
