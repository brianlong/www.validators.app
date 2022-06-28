# frozen_string_literal: true

Sidekiq.configure_server do |config|
  config.redis = {
    url: Rails.application.credentials.dig(:redis, :url)
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: Rails.application.credentials.dig(:redis, :url)
  }
end
