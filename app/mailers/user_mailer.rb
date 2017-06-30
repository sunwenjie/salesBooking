class UserMailer < BaseMailer

  def send_new_user_message(user, raw_token)
    @user = user
    @url = "http://#{CURRENT_DOMAIN}/auth/secret/edit?reset_password_token=#{raw_token}"
    mail(to: "#{@user.useremail}", subject: t('order.form.booking_system_active'))
  end
end