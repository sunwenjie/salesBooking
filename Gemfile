source 'https://rubygems.org/'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.8'
# Use sqlite3 as the database for Active Record
gem 'mysql2','~> 0.3.18'
gem 'i18n'

gem 'awesome_nested_set'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

gem 'devise'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

#order(:position)
gem 'acts_as_list'

#workflow
gem 'state_machine'

# gem 'slim-rails'

gem 'awesome_nested_set'

gem "settingslogic"

gem 'sidekiq'

# gem 'sinatra'

#soft deleted
gem "paranoia", "~> 2.0"

gem 'mini_magick'

gem "carrierwave"
# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development

gem 'thin'

group :development do
  gem 'pry'
  gem 'pry-nav'
  gem 'pry-rails'
end
gem 'cancan'

gem 'axlsx'

gem 'httparty','0.9.0'

group :test,:development do
  gem 'faker'
  gem 'factory_girl_rails'
  gem 'rspec'
  gem "rspec-rails"
  gem "timecop"
  gem 'database_cleaner'
end


group :production,:staging do
  gem 'execjs'
  gem 'therubyracer', :platforms => :ruby
end
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
gem 'capistrano-rails', group: :development
gem 'capistrano-chruby', group: :development


# Use debugger
# gem 'debugger', group: [:development, :test]




# Use bullet for deployment
# Use bullet for deployment
group :development do
  gem 'bullet'
  gem 'ruby-growl'
  gem 'airbrake'
  gem 'honeybadger'
  gem 'rollbar'
  gem 'slack-notifier'
  gem 'uniform_notifier'
  gem 'ruby_gntp'
end

#Use gem 'traceroute'
gem 'traceroute', group: :development
