class XmoGroup < Base
  establish_connection "xmo_production".to_sym
  self.table_name = "groups"
  serialize :childrengroups

  serialize :select_users
end
