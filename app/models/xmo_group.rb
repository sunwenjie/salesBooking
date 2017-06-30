class XmoGroup < Base
  establish_connection :xmo_production
  self.table_name = "groups"
  serialize :childrengroups

  serialize :select_users
end
