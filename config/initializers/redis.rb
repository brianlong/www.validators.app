# frozen_string_literal: true

redis_uri = ENV['REDIS_URL'] || Rails.application.credentials.dig(:redis, :url)
$redis = Redis.new(url: redis_uri)
