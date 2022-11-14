# frozen_string_literal: true

require_relative "../config/environment"
require_relative './concerns/front_software_versions_module.rb'

include FrontSoftwareVersionsModule

@networks = %w[mainnet testnet].freeze
sleep_time = 5 # seconds
update_stats_time = 60 # seconds
@counter = 0
@software_versions = get_versions_for_networks

def get_latest_cluster_stats
  {
    mainnet: ClusterStat.by_network("mainnet").last&.attributes,
    testnet: ClusterStat.by_network("testnet").last&.attributes
  }
end

@last_cluster_stats = get_latest_cluster_stats

loop do
  begin
    @counter += 1

    # Data updates | 1 minute
    if @counter == update_stats_time / sleep_time
      @counter = 0
      @last_cluster_stats = get_latest_cluster_stats
      @software_versions = get_versions_for_networks
    end

    # Data updates | each time
    coin_gecko_response = CoinGeckoClient.new.price
    parsed_response = coin_gecko_response
    parsed_response["cluster_stats"] = @last_cluster_stats
    
    broadcast_software_versions(@software_versions)
    ActionCable.server.broadcast("front_stats_channel", parsed_response)

    sleep(sleep_time)
  rescue => e
    puts e
    puts e.backtrace
    sleep(sleep_time)
    next
  end
end
