source 'https://rubygems.org'

ruby '2.2.4'

gem 'rails', '4.2.0'
# Use mysql/postgres as the database for Active Record

gem 'pg'
# gem 'mysql2'

# Active Record composite primary keys support
gem 'composite_primary_keys'
# Use SCSS for stylesheets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'

gem 'sprockets', '>= 3.0.0'
gem 'sprockets-es6', '0.7.0'

gem 'gibbon'

gem 'less'
gem 'less-rails'
gem 'less-rails-bootstrap'
gem 'therubyracer'
gem 'font-awesome-rails'
# See https://github.com/sstephenson/execjs#readme for more supported runtime
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'active_link_to' # easy way to add class="active"

gem 'beacon_control-base',
    path: 'vendor/gems/beacon_control-base'

gem 'beacon_control-presence_extension',
    path: 'vendor/gems/beacon_control-presence_extension'

gem 'beacon_control-analytics_extension',
    path: 'vendor/gems/beacon_control-analytics_extension'

gem 'beacon_control-dwell_time_extension',
    path: 'vendor/gems/beacon_control-dwell_time_extension'

gem 'beacon_control-kontakt_io_extension',
    path: 'vendor/gems/beacon_control-kontakt_io_extension'

gem 'beacon_control-neighbours_extension',
    path: 'vendor/gems/beacon_control-neighbours_extension'

gem 'beacon_control-backend_request_extension',
    path: 'vendor/gems/beacon_control-backend_request_extension'

# Barcodes
gem 'barby'

gem 'bootstrap-slider-rails'

# File upload and image processing gems
# https://github.com/jnicklas/carrierwave
gem 'carrierwave'

gem 'sidekiq'
gem 'sidekiq-status'
gem 'sinatra', require: nil

# Unified interface for KV stores
gem 'moneta'


gem 'devise'
gem 'devise_security_extension'

gem 'doorkeeper', '~>2.2.0'
gem 'draper', '~>2.0.0'
gem 'enumerize', '~>0.8.0'
gem 'faraday', '~>0.9.0'
gem 'handlebars_assets'
gem 'inherited_resources', branch: 'rails-4-2', github: 'josevalim/inherited_resources'
gem 'responders'
gem 'naught'
gem 'nested_form'
gem 'rpush', '~>2.4.0'

gem 'virtus'

gem 'has_scope'

# QRCode extension for Barby
gem 'rqrcode'

gem 'simple_form', branch: 'bootstrap-3'

gem "deep_merge", :require => 'deep_merge/rails_compat'

gem 'active_model_serializers', '0.9.1'

gem 'cancancan'

gem 'foreman'

gem 'rack-cors', :require => 'rack/cors'

gem 'premailer-rails'

group :development, :test do
  gem 'pry'
  gem 'pry-nav'
  gem 'pry-rails'
  gem 'factory_girl_rails', '~>4.4.1'
  gem 'quiet_assets'
end

group :test do
  gem 'rspec', '~>3.0.0'
  gem 'rspec-rails', '~>3.0.0'
  gem 'database_cleaner'
  gem 'timecop', '~> 0.7.1'
  gem 'capybara'
end

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'letter_opener'
end
