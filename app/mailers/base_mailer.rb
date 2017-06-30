class BaseMailer < ActionMailer::Base

  if Rails.env == "production"
    default from: "sales_notification@i-click.com"
  else
    default from: "sales_notification_staging@i-click.com"
  end

end