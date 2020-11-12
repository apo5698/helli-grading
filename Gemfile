source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.1'

gem 'active_model_serializers'
gem 'activerecord-session_store'
gem 'aws-sdk-s3'
gem 'bcrypt'
gem 'bootsnap', require: false
gem 'colorize'
gem 'devise'
gem 'pg'
gem 'puma'
gem 'rails'
gem 'rubyzip'
gem 'sass-rails'
gem 'sidekiq'
gem 'turbolinks'
gem 'webpacker'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'rubocop-rails'
  gem 'spring'
  gem 'spring-watcher-listen'
end

group :test do
  gem 'capybara'
  gem 'coveralls', require: false
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'guard-rspec'
  gem 'rspec-its'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end

group :development, :test do
  gem 'dotenv-rails'
  gem 'faker', github: 'faker-ruby/faker'
  gem 'rubocop'
  gem 'rubocop-faker'
  gem 'rubocop-rspec'
end
