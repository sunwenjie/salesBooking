class LocationCode < ActiveRecord::Base
  establish_connection "xmo_production".to_sym
  # establish_connection "xmo_development".to_sym

end