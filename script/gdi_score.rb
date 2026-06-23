# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)
require 'uri'
require 'net/http'
require 'net/protocol'

RETRY_MAX = 5 unless defined?(RETRY_MAX)
SLEEP_TIME = 10 unless defined?(SLEEP_TIME)

retry_count = 0

begin
  uri = URI("https://gdindex.app/gdi/leaderboard-latest.json")
  response = Net::HTTP.get_response(uri)

  unless response.is_a?(Net::HTTPSuccess)
    raise Net::HTTPError.new("Failed to fetch data from API. Status: #{response.code}", response)
  end

  json_data = JSON.parse(response.body)

  raise "No pools data returned from API" if json_data['pools'].nil?

  pools = json_data['pools']

  raise "No pools found in API response" if pools.empty?

  # GDI pool_name (e.g. "bSOL", "JitoSOL") lowercased matches our ticker field
  score_map = pools.each_with_object({}) { |p, h| h[p['pool_name'].downcase] = p['gdi'].to_f }

  stake_pools = StakePool.where(network: 'mainnet')

  ids_and_scores = stake_pools.filter_map do |pool|
    score = score_map[pool.ticker&.downcase]
    next unless score
    [pool.id, score]
  end

  if ids_and_scores.any?
    case_sql = ids_and_scores.map { |id, score| "WHEN #{id} THEN #{score}" }.join(" ")
    StakePool.where(id: ids_and_scores.map(&:first))
             .update_all("gdi_score = CASE id #{case_sql} END")
  end
rescue Net::HTTPError, Net::OpenTimeout, Net::ReadTimeout, SocketError, Errno::ECONNREFUSED => e
  retry_count += 1
  if retry_count < RETRY_MAX
    sleep(SLEEP_TIME)
    retry
  end
end
