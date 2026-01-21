# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)
require 'uri'
require 'net/http'

network = ARGV[0] || 'mainnet'

uri = URI("https://explorer.bam.dev/api/v1/ibrl_validators")
response = Net::HTTP.get_response(uri)

if response.is_a?(Net::HTTPSuccess)
  json_data = JSON.parse(response.body)
  
  if json_data['data'].nil?
    puts "No data returned from API"
    exit
  end

  identities = json_data['data'].map { |d| d['identity'] }

  validators = Validator.where(account: identities, network: network)
                        .includes(:validator_score_v1)
                        .index_by(&:account)

  ValidatorScoreV1.transaction do
    json_data['data'].each do |validator_data|
      identity = validator_data['identity']
      ibrl_score = validator_data['ibrl_score']

      validator = validators[identity]

      if validator.nil? || validator.validator_score_v1.nil?
        next
      end

      validator.validator_score_v1.update_column(:ibrl_score, ibrl_score)
    end
  end

else
  puts "Failed to fetch data from API. Status: #{response.code}"
end
