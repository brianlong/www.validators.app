# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)
require 'uri'
require 'net/http'

RETRY_MAX = 5
SLEEP_TIME = 10

retry_count = 0
network = ARGV[0] || 'mainnet'

begin
  uri = URI("https://explorer.bam.dev/api/v1/ibrl_validators")
  response = Net::HTTP.get_response(uri)

  raise "Failed to fetch data from API. Status: #{response.code}" unless response.is_a?(Net::HTTPSuccess)

  json_data = JSON.parse(response.body)
  
  exit if json_data['data'].nil?

  identities = json_data['data'].reject { |d| d['ibrl_score'] == 0 }.map { |d| d['identity'] }

  raise "No validators with non-zero ibrl_score found" if identities.empty?

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
rescue => e
  retry_count += 1
  if retry_count < RETRY_MAX
    sleep(SLEEP_TIME)
    retry
  end
end
