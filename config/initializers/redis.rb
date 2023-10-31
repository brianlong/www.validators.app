# frozen_string_literal: true

$redis = Redis.new(url: Rails.application.credentials.dig(:redis, :url))
