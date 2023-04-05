class Rack::Attack
  Rack::Attack.cache.store = Redis.new(url: Rails.application.credentials.dig(:redis, :rack_attack))

  API_ENDPOINTS_WITH_HIGH_LIMIT = [
    "/api/v1/commission-changes",
    "/api/v1/ping-thing",
    "/api/v1/ping-thing-stats"
  ].freeze

  API_LOW_LIMIT = 30
  API_HIGH_LIMIT = 60
  LIMIT_RESET_PERIOD = 5.minute

  ### Throttle Spammy Clients ###
  # Throttle GET requests to API by user authorization token
  #
  # Set higher limit for API requests defined in API_ENDPOINTS_WITH_HIGH_LIMIT constant
  # Key: "rack::attack:#{Time.now.to_i/:period}:req-api-high/user:#{KEY}"
  #  eg. "rack::attack:5590831:req-api-high/user:abcde-edcba"
  throttle("req-api-high/user", limit: API_HIGH_LIMIT, period: LIMIT_RESET_PERIOD) do |req|
    if req.path.start_with?(*API_ENDPOINTS_WITH_HIGH_LIMIT) && req.get?
      token = req.env["HTTP_TOKEN"] || req.env["HTTP_AUTHORIZATION"]
      "#{token[0..5]}-#{token[-5..-1]}" if token
    end
  end

  # Set default limit for other API GET requests
  # Key: "rack::attack:#{Time.now.to_i/:period}:req-api-low/user:#{KEY}"
  throttle("req-api-low/user", limit: API_LOW_LIMIT, period: LIMIT_RESET_PERIOD) do |req|
    if !req.path.start_with?(*API_ENDPOINTS_WITH_HIGH_LIMIT) && req.path.start_with?("/api/v1/") && req.get?
      token = req.env["HTTP_TOKEN"] || req.env["HTTP_AUTHORIZATION"]
      "#{token[0..5]}-#{token[-5..-1]}" if token
    end
  end

  ### Custom Throttle Response ###
  # By default, Rack::Attack returns an HTTP 429 for throttled responses and no headers.
  # Uncomment the lines below to customize the response.
  self.throttled_responder = lambda do |req|
    match_data = req.env["rack.attack.match_data"]
    reset_time = match_data[:period] # LIMIT_RESET_PERIOD in seconds
    used_time = match_data[:epoch_time].to_i % reset_time # in seconds
    remaining_time_till_reset = (reset_time - used_time).to_s

    headers = {
      "RateLimit-Limit" => match_data[:limit].to_s,
      "RateLimit-Remaining" => "0",
      "RateLimit-Reset" => remaining_time_till_reset
    }

    [ 429, headers, ["Too Many Requests. Retry later.\n"]]
  end

  ### Define whitelists ###

  # Allow all internal requests
  self.safelist("allow internal requests") do |req|
    key = Rails.application.credentials.api_authorization
    req.env["HTTP_AUTHORIZATION"] == key
  end

  # Allow no limit requests to specified endpoints or for specified users
  # Uncomment and edit the following lines to allow no limit requests
  # self.safelist("allow all requests to PATH") do |req|
  #   req.path.start_with?("/api/v1/PATH") && req.get?
  # end

  # Set no limits to all endpoints for listed users
  self.safelist("allow all requests for users") do |req|
    user_token = req.env["HTTP_TOKEN"] || req.env["HTTP_AUTHORIZATION"]
    whitelisted_tokens = Rails.application.credentials.dig(:rack_attack, :whitelist_all_endpoints)
    user_token.in? whitelisted_tokens
  end
end
