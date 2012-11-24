source 'http://rubygems.org'

gem 'rails', '3.1.3'

gem 'bcrypt-ruby', '~> 3.0.0'
gem 'delayed_job_active_record'
gem 'dynamic_form'
gem 'exception_notification'
gem 'jquery-rails'
gem 'redcarpet'
gem 'rest-client'
gem 'valid_email'

group :production do
  gem 'pg'
end

group :development, :test do
  gem 'mysql2'
  gem 'ruby-debug19', require: 'ruby-debug'
  gem 'heroku'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.1.5'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
end

group :test do
  # Pretty printed test output
  gem 'turn', require: false
  gem 'minitest'
  gem 'spinach'
  gem 'spinach-rails'
  gem 'timecop'
end
