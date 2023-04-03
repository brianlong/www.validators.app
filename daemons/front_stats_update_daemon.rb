# frozen_string_literal: true

require_relative "../config/environment"
require_relative './concerns/front_software_versions_module.rb'

include FrontSoftwareVersionsModule

sleep_time = 5 # seconds
update_stats_time = 60 # seconds
@counter = 0
@software_versions = get_versions_for_networks
@coin_gecko_response = nil

def get_latest_cluster_stats
  {
    mainnet: ClusterStat.by_network("mainnet").last&.attributes,
    testnet: ClusterStat.by_network("testnet").last&.attributes,
    pythnet: ClusterStat.by_network("pythnet").last&.attributes
  }
end

def update_prices
  @coin_gecko_response = begin
    CoinGeckoClient.new.price
  rescue CoinGeckoClient::CoinGeckoResponseError
    @coin_gecko_response || {}
  end
end

@last_cluster_stats = get_latest_cluster_stats
update_prices

loop do
  begin
    @counter += 1

    # Data updates | each 1 minute
    if @counter == update_stats_time / sleep_time
      @counter = 0
      @last_cluster_stats = get_latest_cluster_stats
      @software_versions = get_versions_for_networks
      update_prices
    end

    # Data updates | each 10 seconds
    if @counter % 2 == 0
      update_prices
    end

    # Data updates | each 5 seconds
    parsed_response = @coin_gecko_response
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
