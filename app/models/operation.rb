class Operation < ActiveRecord::Base

  ACTIONS = %w{processing materials_incomplete need_third_code config_done}

  belongs_to :order,inverse_of: :operations, touch:true
  has_many :share_ams
  validates :action, presence: true

end
