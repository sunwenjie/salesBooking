class BshareIndustry < ActiveRecord::Base
  establish_connection "xmo_production".to_sym
end
