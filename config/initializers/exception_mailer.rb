rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'production'

mailer_config = YAML.load_file(rails_root + '/config/exception_mailer.yml')

SEND_EMAIL = mailer_config[rails_env]['sendmail']
RECIPIENTS = mailer_config[rails_env]['recipients']
PV_RECIPIENTS = mailer_config[rails_env]['pv_recipients']

