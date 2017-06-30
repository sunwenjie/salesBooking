class ErrorWorker
  include Sidekiq::Worker

  def perform(recipients,msg)
    ErrorMailer.send_error_message(recipients, msg).deliver
    ActiveRecord::Base.clear_active_connections!
  end

end