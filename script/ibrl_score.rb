# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)
require 'uri'
require 'net/http'

uri = URI("https://ibrl.wtf/api/v1/ibrl_validators/")
response = Net::HTTP.get_response(uri)

puts response
if response.is_a?(Net::HTTPSuccess)
  data = JSON.parse(response.body)
  puts data
end