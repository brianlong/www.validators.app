# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# OpenSSH keys only supported if ED25519 is available (NotImplementedError)
# net-ssh requires the following gems for ed25519 support:
#  * ed25519 (>= 1.2, < 2.0)
#  * bcrypt_pbkdf (>= 1.0, < 2.0)
# See https://github.com/net-ssh/net-ssh/issues/565 for more information
# Gem::LoadError : "ed25519 is not part of the bundle. Add it to your Gemfile."

gem 'bundler', '>= 2.1'
gem 'json', '>= 2.3.0'

gem 'websocket-extensions', '>= 0.1.5'

gem 'actionview', '>= 6.0.3.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.1'

# Use mysql as the database for Active Record
gem 'mysql2', '>= 0.5.3'

# Use Passenger as the app server
# gem 'passenger'

# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 5.4'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'

# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.8.1'

# This is for the free version of Sidekiq.
gem 'sidekiq', ' ~> 7.1'

# Use this for SideKiq Pro if you have our production keys
# source 'https://gems.contribsys.com/' do
#   gem 'sidekiq-pro'
# end

# Crontab manager
gem 'whenever', require: false

# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
gem 'image_processing'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.16', require: false

# Capistrano
gem 'capistrano-passenger', '>= 0.2.1'
gem 'capistrano-rails', group: :development

# AppSignal
gem 'appsignal'

gem "mechanize", ">= 2.9.1"
gem 'nokogiri', '1.15.5'

# Pagination
gem 'kaminari'

# MaxMind
gem 'dnsruby'
gem 'maxmind-geoip2'

# use rack-cors for cross-origin api queries
gem 'rack-cors'

# Ruby client for Solana
gem 'solana_rpc_ruby'

# Ruby client for CoinGecko
gem 'coingecko_ruby'

gem "audited", "~> 5.3.3"

gem 'sitemap_generator', '~> 6.3.0'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'bullet', '~> 7.0'
  gem 'factory_bot_rails'
  gem 'faker', git: 'https://github.com/faker-ruby/faker.git', branch: 'master'
  gem 'pronto', '~> 0.11.2'
  gem 'pronto-flay', '~> 0.11.1', require: false
  gem 'pronto-rubocop', '~> 0.11.5', require: false
  gem 'pry', '~> 0.14.2'
  gem 'rubocop', '~> 1.18', require: false
  gem 'letter_opener_web'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Access an interactive console on exception pages or by calling 'console'
  # anywhere in the code.
  gem 'web-console', '>= 4.2.1'
  # Spring speeds up development by keeping your application running in the
  # background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
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
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# NOTE: This template allows you to choose between encryption with the
# `attr_encrypted` gem or Vault. Vault is more secure but is harder to
# configure in production.
#
# User data encryption
gem 'attr_encrypted', '>= 4.0'

# Or use this for Vault. NOTE: Use this version of the gem until
# https://github.com/hashicorp/vault-rails/pull/76 is merged:
# gem 'vault-rails',
#     git: 'https://github.com/madding/vault-rails.git',
#     branch: 'fix-dirty-changed-attributes'

# Assets storage
gem 'aws-sdk-s3', require: false

# Authentication
gem 'devise'
gem 'devise-i18n'

# https://github.com/ambethia/recaptcha
gem 'recaptcha'

# User browser detection
gem 'browser'

# PDFs creator
gem 'wkhtmltopdf-binary'
gem 'wicked_pdf'

# Requests limiter
gem 'rack-attack'
