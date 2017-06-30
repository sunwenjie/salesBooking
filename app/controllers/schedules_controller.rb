
class SchedulesController < ApplicationController
  #include SendEmail
  include SendAxlsx
def index
  
end

def show_schedule
  @order=Order.find(params[:order_id])
  send_schedule_xlsx(params[:order_id])
end

end
