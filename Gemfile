# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.0'
gem 'bundler', '>= 2.1'
gem 'json', '>= 2.3.0'

gem 'actionview', '>= 6.0.3.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0'

# Use mysql as the database for Active Record
gem 'mysql2', '>= 0.5.3'

# Use Passenger as the app server
# gem 'passenger'

# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 4.0'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'

# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'

# This is for the free version of Sidekiq.
gem 'sidekiq'

# Use this for SideKiq Pro if you have our production keys
# source 'https://gems.contribsys.com/' do
#   gem 'sidekiq-pro'
# end

# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

# Capistrano
gem 'capistrano-passenger'
gem 'capistrano-rails', group: :development
gem 'capistrano-sidekiq', require: false

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'faker', git: 'https://github.com/faker-ruby/faker.git', branch: 'master'
  gem 'pry', '~> 0.12.2'
  gem 'rubocop'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Access an interactive console on exception pages or by calling 'console'
  # anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the
  # background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# NOTE: This template allows you to choose between encryption with the
# `attr_encrypted` gem or Vault. Vault is more secure but is harder to
# configure in production.
#
# Use this gem for attr_encrypted:
gem 'attr_encrypted', '>= 3.1.0'

# Or use this for Vault. NOTE: Use this version of the gem until
# https://github.com/hashicorp/vault-rails/pull/76 is merged:
# gem 'vault-rails',
#     git: 'https://github.com/madding/vault-rails.git',
#     branch: 'fix-dirty-changed-attributes'

# For asset storage
gem 'aws-sdk-s3', require: false

gem 'devise'
gem 'devise-i18n'
