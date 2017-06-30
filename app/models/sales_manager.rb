class SalesManager < User

  has_many :groups, inverse_of: :sales_manager

  def self.unapproved(current_user_id)
     self.find(current_user_id).groups.inject([]){|o,g| g.users.inject([]){|c,u| u.clients.with_state("unapproved").descend_by_updated_at.each{|b|c<<b};c }.each{|a|o<<a}; o}.sort_by{|u|u.updated_at}.reverse
  end

  def self.approved(current_user_id)
     self.find(current_user_id).groups.inject([]){|o,g| g.users.inject([]){|c,u| u.clients.with_state("approved","cli_rejected").descend_by_updated_at.each{|b|c<<b};c }.each{|a|o<<a}; o}.sort_by{|u|u.updated_at}.reverse
  end

end