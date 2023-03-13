class Rack::Attack
  Rack::Attack.cache.store = Redis.new(url: Rails.application.credentials.dig(:redis, :rack_attack))

  API_ENDPOINTS_WITH_HIGH_LIMIT = [
    "/api/v1/commission-changes",
    "/api/v1/ping-thing",
    "/api/v1/ping-thing-stats"
  ].freeze

  ### Throttle Spammy Clients ###
  # Throttle GET requests to API by user authorization token
  #
  # Set higher limit for API requests defined in API_ENDPOINTS_WITH_HIGH_LIMIT constant
  # Key: "rack::attack:#{Time.now.to_i/:period}:req-api-high/user:#{KEY}"
  #  eg. "rack::attack:5590831:req-api-high/user:abcde-edcba"
  throttle("req-api-high/user", limit: 40, period: 5.minutes) do |req|
    if req.path.start_with?(*API_ENDPOINTS_WITH_HIGH_LIMIT) && req.get?
      token = req.env["HTTP_TOKEN"] || req.env["HTTP_AUTHORIZATION"]
      "#{token[0..5]}-#{token[-5..-1]}"
    end
  end

  # Set default limit for other API GET requests
  # Key: "rack::attack:#{Time.now.to_i/:period}:req-api-low/user:#{KEY}"
  throttle("req-api-low/user", limit: 25, period: 5.minutes) do |req|
    if !req.path.start_with?(*API_ENDPOINTS_WITH_HIGH_LIMIT) && req.path.start_with?("/api/v1/") && req.get?
      token = req.env["HTTP_TOKEN"] || req.env["HTTP_AUTHORIZATION"]
      "#{token[0..5]}-#{token[-5..-1]}"
    end
  end

  ### Custom Throttle Response ###
  # By default, Rack::Attack returns an HTTP 429 for throttled responses.
  # If you want to customize the response, then uncomment the lines below.
  self.throttled_response = lambda do |env|
    [ 429, {}, ["Too Many Requests. Retry later.\n"]]
  end
end

### Define whitelists ###

# Allow all internal requests
Rack::Attack.safelist("allow internal requests") do |req|
  key = Rails.application.credentials.api_authorization
  req.env["HTTP_AUTHORIZATION"] == key
end

# Allow no limit requests to specified endpoints or for specified users
# Uncomment and edit the following lines to allow no limit requests
# Rack::Attack.safelist("allow all requests to PATH") do |req|
#   req.path.start_with?("/api/v1/PATH") && req.get?
# end
# Rack::Attack.safelist("allow all requests for USER") do |req|
#   req.env["HTTP_AUTHORIZATION"] == USER_AUTHORIZATION_KEY
# end
