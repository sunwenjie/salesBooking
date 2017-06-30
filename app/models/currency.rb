class Currency < ActiveRecord::Base
  establish_connection "xmo_production".to_sym
  has_many :clients
end