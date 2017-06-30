class ErrorMailer < BaseMailer

  def send_error_message(recipients,msg)
    @msg = msg
    @exception_date = Time.now
    mail(to: recipients, subject: t('order.form.booking_system_error'))
  end

  def send_import_pv_error_message(recipients,msg=nil)
  	@msg = t('order.form.upload_pv_file')
    @exception_date = Time.now
    mail(to: recipients, subject: t('order.form.upload_pv_error'))
  end
end