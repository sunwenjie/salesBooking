class XmoUser < Base
  establish_connection :xmo_production
  self.table_name = "users"
  serialize :roles
  serialize :innergroups
  serialize :bu
end
