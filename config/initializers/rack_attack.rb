# Define requests whitelist
Rack::Attack.safelist("mark any authenticated access safe") do |request|
  # Requests are allowed if coming from the app
  authorization_key = Rails.application.credentials.api_authorization
  whitelisted_host = !!(request.env["HTTP_HOST"] =~ /validators.app/)

  request.env["HTTP_AUTHORIZATION"] == authorization_key || whitelisted_host
end

# TODO Always allow requests from localhost
# Rack::Attack.safelist('allow from localhost') do |request|
#   '127.0.0.1' == request.ip || '::1' == request.ip
#   !!(request.env["HTTP_HOST"] =~ /localhost:/)
# end
