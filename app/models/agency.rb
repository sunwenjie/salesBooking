class Agency < ActiveRecord::Base
  establish_connection "xmo_production".to_sym
  has_many :users

  def active?
    status == 'ACTIVE'
  end

end
