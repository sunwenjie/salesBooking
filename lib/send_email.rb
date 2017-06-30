module SendEmail
    #include this module to class::Order and Client
    #use like that--  Order.first.send_email
    def send_email
      Email.call_email(self)
    end
    
end
