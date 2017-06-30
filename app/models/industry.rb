class Industry < Base
  establish_connection "xmo_production".to_sym
  has_many :orders, inverse_of: :industry
  has_many :clients
end
