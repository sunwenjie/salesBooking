class Order < Base

  attr_reader :approver #审批者
  
  def approver
   return nil if @approver.nil?
   u = User.find_by(User.user_conditions(@approver))
  end

  def approver=(user)
    u = User.find_by(User.user_conditions(user))
    #throw "approver does not exist"  if u.nil?
    @approver = u
  end

end