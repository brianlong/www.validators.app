class Rack::Attack
  ### Throttle Spammy Clients ###
  # Throttle all requests by IP (60rpm)
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
  throttle('req/ip', limit: 2, period: 2.minutes) do |req| # TODO adjust limit
    if req.path.start_with?('/api/v1/') && req.get?
      req.ip
    end
  end

  ### Prevent Brute-Force Login Attacks ###
  # Throttle POST requests to /login by IP address
  # Key: "rack::attack:#{Time.now.to_i/:period}:logins/ip:#{req.ip}"
  throttle('logins/ip', limit: 5, period: 20.seconds) do |req|
    if req.path == '/users/sign_in' && req.post?
      req.ip
    end
  end

  ### Custom Throttle Response ###
  # By default, Rack::Attack returns an HTTP 429 for throttled responses.
  # If you want to return 503 or you just want to customize the response), then uncomment the lines below.
  self.throttled_response = lambda do |env|
    [ 503, {}, ["Server Error\n"]]
  end
end

### Define whitelists ###
# TODO Allow all internal requests
# Rack::Attack.safelist("allow internal requests") do |req|
#   internal_authorization_key = (req.env["HTTP_AUTHORIZATION"] == Rails.application.credentials.api_authorization)
#   internal_host = !!(req.env["HTTP_HOST"] =~ /validators.app/)
#   internal_authorization_key || internal_host
# end

# Allow no limit requests to specific endpoints
# Uncomment and edit the following lines to allow no limit requests to some methods
# Rack::Attack.safelist("allow post requests to PATH") do |req|
#   req.path.start_with?("/api/v1/PATH") && req.getg?
# end

# TODO Always allow requests from localhost
# Rack::Attack.safelist('allow from localhost') do |req|
#   '127.0.0.1' == req.ip || '::1' == req.ip
#   !!(req.env["HTTP_HOST"] =~ /localhost:/)
# end
