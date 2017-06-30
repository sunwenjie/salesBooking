class UserWorker
  include Sidekiq::Worker

  def perform(user_id, raw_token)
    user = User.find(user_id)
    UserMailer.send_new_user_message(user, raw_token).deliver
    ActiveRecord::Base.clear_active_connections!
  end

end