class Rack::Attack
  Rack::Attack.cache.store = Redis.new(url: Rails.application.credentials.dig(:redis, :rack_attack))

  API_ENDPOINTS_WITH_HIGH_LIMIT = [
    "/api/v1/commission-changes",
    "/api/v1/ping-thing",
    "/api/v1/ping-thing-stats"
  ].freeze

  ### Throttle Spammy Clients ###
  # Throttle GET requests to API by IP
  #
  # Set higher limit for API requests defined in constant
  # Key: "rack::attack:#{Time.now.to_i/:period}:req-api-high/ip:#{req.ip}"
  #  eg. "rack::attack:5590831:req-api-high/ip:127.0.0.1"
  throttle("req-api-high/ip", limit: 35, period: 5.minutes) do |req|
    if req.path.start_with?(*API_ENDPOINTS_WITH_HIGH_LIMIT) && req.get?
      req.ip
    end
  end

  # Set default limit for other API requests
  # Key: "rack::attack:#{Time.now.to_i/:period}:req-api-low/ip:#{req.ip}"
  throttle("req-api-low/ip", limit: 20, period: 5.minutes) do |req|
    if !req.path.start_with?(*API_ENDPOINTS_WITH_HIGH_LIMIT) && req.path.start_with?("/api/v1/") && req.get?
      req.ip
    end
  end

  ### Prevent Brute-Force Login Attacks ###
  # Throttle POST requests to sign in page by IP address
  # Key: "rack::attack:#{Time.now.to_i/:period}:logins/ip:#{req.ip}"
  throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
    if req.path == "/users/sign_in" && req.post?
      req.ip
    end
  end

  ### Custom Throttle Response ###
  # By default, Rack::Attack returns an HTTP 429 for throttled responses.
  # If you want to customize the response), then uncomment the lines below.
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

# Allow no limit requests to specific endpoints
# Uncomment and edit the following lines to allow no limit requests to some methods
# Rack::Attack.safelist("allow all requests to PATH") do |req|
#   req.path.start_with?("/api/v1/PATH") && req.get?
# end
