# frozen_string_literal: true

source 'https://rubygems.org'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 8.1'

# Asset pipeline
gem 'propshaft'

# Use sqlite3 as the database for Active Record
gem 'sqlite3', '~> 2.1'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 5.0'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Use Redis adapter to run Action Cable in production
gem 'redis', '>= 4.0.1'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  gem 'debug', platforms: %i[mri windows]
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-capybara', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rspec_rails', require: false
  gem 'solr_wrapper', '>= 0.3'
end

group :development do
  gem 'dotenv-rails'
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
end

# Incorporating blacklight
gem 'blacklight', '~> 9.0'
gem 'blacklight_range_limit', '~> 9.2'

# CSV needs to be added explicitly post ruby 3.4
gem 'csv'

gem 'bot_challenge_page', '~> 1.2'
gem 'config'
gem 'dotenv'
gem 'okcomputer'
gem 'openssl'
gem 'pg'
gem 'recaptcha', '~> 5.21'
gem 'rsolr', '>= 1.0', '< 3'

# For Capistrano
group :deployment do
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-maintenance', '~> 1.2', require: false
  gem 'capistrano-passenger'
  gem 'capistrano-rails'
  gem 'capistrano-rvm'
  gem 'dlss-capistrano', require: false
end
