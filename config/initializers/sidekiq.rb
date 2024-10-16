# frozen_string_literal: true

Sidekiq.configure_server do |config|
  config.redis = {
    url: Rails.application.credentials.dig(:redis, :url)
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
    url: Rails.application.credentials.dig(:redis, :url)
  }

  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
  end
end
