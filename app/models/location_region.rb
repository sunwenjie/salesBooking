class LocationRegion < ActiveRecord::Base
  establish_connection "xmo_production".to_sym
end