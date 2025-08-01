# frozen_string_literal: true

redis_uri = ENV['REDIS_URL'] || Rails.application.credentials.dig(:redis, :url)

Sidekiq.configure_server do |config|
  config.redis = {
    url: redis_uri
  }
  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
  end

  config.server_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Server
  end

  SidekiqUniqueJobs::Server.configure(config)
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: redis_uri
  }

  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
  end
end
