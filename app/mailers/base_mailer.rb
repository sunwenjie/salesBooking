class BaseMailer < ActionMailer::Base

  if Rails.env == "production"
    default from: "sales_notification@i-click.com",
            content_type: "text/html"

  else
    default from: "sales_notification_staging@i-click.com",
            content_type: "text/html"
  end

end