class OrderNonuniform < ActiveRecord::Base
  belongs_to :order, inverse_of: :order_nonuniforms
end
