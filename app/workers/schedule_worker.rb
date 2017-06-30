class ScheduleWorker
  include Sidekiq::Worker

  def perform(order_id)
    begin
      Order.find(order_id).generate_schedule
    rescue => e
      ErrorMailer.send_error_message(RECIPIENTS, e.message.to_s).deliver
    end
  end

end