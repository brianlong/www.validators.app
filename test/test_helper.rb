# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'faker'
require 'minitest/mock'

Dir[Rails.root.join('test/support/**/*')].sort.each { |f| require f }

VCR.configure do |config|
  config.cassette_library_dir = 'test/vcr_cassettes'
  config.hook_into :webmock
  # config.default_cassette_options = { record: :new_episodes }
  config.allow_http_connections_when_no_cassette = false

  config.ignore_request do |request|
    uri = URI(request.uri)
    # ignore only localhost requests to port 7500
    uri.host == '127.0.0.1' && uri.port == 8899
  end

  config.filter_sensitive_data("<TOKEN>") do |interaction|
    interaction.request.headers["Authorization"]&.first
  end
end

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  # parallelize(workers: :number_of_processors)
  parallelize(workers: 1)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  include FactoryBot::Syntax::Methods
  # Add more helper methods to be used by all tests here...
end
