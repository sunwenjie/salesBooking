class UsersGroup < Base
  establish_connection :xmo_production
  belongs_to :user
  belongs_to :group
end
