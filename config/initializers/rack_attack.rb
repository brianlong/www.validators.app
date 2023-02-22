# Define requests whitelists

Rack::Attack.safelist("allow internal requests") do |request|
  internal_authorization_key = (request.env["HTTP_AUTHORIZATION"] == Rails.application.credentials.api_authorization)
  internal_host = !!(request.env["HTTP_HOST"] =~ /validators.app/)
  internal_authorization_key || internal_host
end

Rack::Attack.safelist("allow post requests to specified endpoints") do |request|
  # ping thing POST requests
  puts request.path
  request.path.start_with?("/api/v1/ping-thing") && request.request_method == "POST"
end

# TODO Always allow requests from localhost
# Rack::Attack.safelist('allow from localhost') do |request|
#   '127.0.0.1' == request.ip || '::1' == request.ip
#   !!(request.env["HTTP_HOST"] =~ /localhost:/)
# end
