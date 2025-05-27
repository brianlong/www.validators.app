# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# OpenSSH keys only supported if ED25519 is available (NotImplementedError)
# net-ssh requires the following gems for ed25519 support:
#  * ed25519 (>= 1.2, < 2.0)
#  * bcrypt_pbkdf (>= 1.0, < 2.0)
# See https://github.com/net-ssh/net-ssh/issues/565 for more information
# Gem::LoadError : "ed25519 is not part of the bundle. Add it to your Gemfile."

gem 'bundler', '>= 2.3.26'
gem 'json', '~> 2.9.1'

gem 'websocket-extensions', '>= 0.1.5'
gem 'faye-websocket', '~> 0.12.0'
gem 'eventmachine', '~> 1.2.7'

gem 'actionview', '>= 6.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.1'
gem 'rack', '= 2.2.8'
gem 'concurrent-ruby', '= 1.3.4'

# Use mysql as the database for Active Record
gem 'mysql2', '>= 0.5.6'

# Use Passenger as the app server
# gem 'passenger'

# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 5.4.4'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.11'

# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.8.1'

# This is for the free version of Sidekiq.
gem 'sidekiq', ' ~> 7.2'
gem 'sidekiq-unique-jobs', '~> 8.0.10'

# Use this for SideKiq Pro if you have our production keys
# source 'https://gems.contribsys.com/' do
#   gem 'sidekiq-pro'
# end

# Crontab manager
gem 'whenever', require: false

# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
gem 'image_processing', '~> 1.14'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.18', require: false

# Capistrano
gem 'capistrano-passenger', '>= 0.2.1'
gem 'capistrano-rails', group: :development

# AppSignal
gem 'appsignal', '~> 4.5'

gem "mechanize", ">= 2.10"
gem 'nokogiri', '1.16.2'
gem 'parallel', '~> 1.27'

# Pagination
gem 'kaminari', '~> 1.2.2'

# MaxMind
gem 'dnsruby', '~> 1.72.4'
gem 'maxmind-geoip2', '~> 1.3.0'

# use rack-cors for cross-origin api queries
gem 'rack-cors', '~> 1.1.1'

# Ruby client for Solana
gem 'solana_rpc_ruby'

# Ruby client for CoinGecko
gem 'coingecko_ruby', '~> 0.4.2'

gem "audited", "~> 5.8"

gem 'sitemap_generator', '~> 6.3.0'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# NOTE: This template allows you to choose between encryption with the
# `attr_encrypted` gem or Vault. Vault is more secure but is harder to
# configure in production.
#
# User data encryption
gem 'attr_encrypted', '>= 4.2'

# Or use this for Vault. NOTE: Use this version of the gem until
# https://github.com/hashicorp/vault-rails/pull/76 is merged:
# gem 'vault-rails',
#     git: 'https://github.com/madding/vault-rails.git',
#     branch: 'fix-dirty-changed-attributes'

# Assets storage
gem 'aws-sdk-s3', require: false

# Authentication
gem 'devise', '~> 4.9'
gem 'devise-i18n', '~> 1.13'

# https://github.com/ambethia/recaptcha
gem 'recaptcha', '~> 5.19'

# User browser detection
gem 'browser', '~> 5.3'

# PDFs creator
gem 'wkhtmltopdf-binary', '~> 0.12.6'
gem 'wicked_pdf', '~> 2.8.2'

# Requests limiter
gem 'rack-attack', '~> 6.6.1'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'bullet', '~> 7.1'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'pry', '~> 0.14.2'
  gem 'letter_opener_web'
  gem 'pronto', '~> 0.11.2'
  gem 'pronto-flay', '~> 0.11.1', require: false
  gem 'pronto-rubocop', '~> 0.11.5', require: false
  gem 'rubocop', '~> 1.63.3', require: false
  gem 'rubocop-rails', '~> 2.24.1', require: false
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Access an interactive console on exception pages or by calling 'console'
  # anywhere in the code.
  gem 'web-console', '>= 4.2.1'
  # Spring speeds up development by keeping your application running in the
  # background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 4.2.1'
  gem 'spring-watcher-listen', '~> 2.1.0'
  gem 'annotate'
  gem 'ed25519'
  gem 'bcrypt_pbkdf'
  gem 'puma', '~> 6.4.2'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 3.39.2'
  gem 'rails-controller-testing'
  gem 'selenium-webdriver'
  gem 'timecop'
  # VCR to record & save network events in tests
  gem 'vcr'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
  gem 'webmock'
  gem 'database_cleaner-active_record'
end
