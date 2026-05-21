# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)
require 'uri'
require 'net/http'
require 'net/protocol'

RETRY_MAX = 5 unless defined?(RETRY_MAX)
SLEEP_TIME = 10 unless defined?(SLEEP_TIME)

retry_count = 0
network = ARGV[0] || 'mainnet'

begin
  uri = URI("https://explorer.bam.dev/api/v1/ibrl_validators")
  response = Net::HTTP.get_response(uri)

  unless response.is_a?(Net::HTTPSuccess)
    raise Net::HTTPError.new("Failed to fetch data from API. Status: #{response.code}", response)
  end

  json_data = JSON.parse(response.body)
  
  raise "No data returned from API" if json_data['data'].nil?

  identities = json_data['data'].reject { |d| d['ibrl_score'] == 0 }.map { |d| d['identity'] }

  raise "No validators with non-zero ibrl_score found" if identities.empty?

  validators = Validator.where(account: identities, network: network)
                        .includes(:validator_score_v1)
                        .index_by(&:account)

  score_map = json_data['data'].each_with_object({}) { |d, h| h[d['identity']] = d['ibrl_score'] }

  ids_and_scores = validators.filter_map do |account, validator|
    next unless validator.validator_score_v1
    [validator.validator_score_v1.id, score_map[account].to_f]
  end

  if ids_and_scores.any?
    case_sql = ids_and_scores.map { |id, score| "WHEN #{id} THEN #{score}" }.join(" ")
    ValidatorScoreV1.where(id: ids_and_scores.map(&:first))
                    .update_all("ibrl_score = CASE id #{case_sql} END")
  end
rescue Net::HTTPError, Net::OpenTimeout, Net::ReadTimeout, SocketError, Errno::ECONNREFUSED => e
  retry_count += 1
  if retry_count < RETRY_MAX
    sleep(SLEEP_TIME)
    retry
  end
end
