class UsersGroup < Base
  establish_connection "xmo_production".to_sym
  belongs_to :user
  belongs_to :group
end
