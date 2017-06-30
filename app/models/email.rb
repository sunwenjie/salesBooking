class Email < ActionMailer::Base
  default :from => "i-click@i-click.com"

  def self.call_email(obj)
    define_method "#{obj.state}" do |obj|
      @obj_case = obj
      mail(:to => @obj_case.user.useremail, :subject => "iClick 订单管理系统 - 订单#{@obj_case.code}等待审批")
    end
    send("#{obj.state}").deliver
  end

end
