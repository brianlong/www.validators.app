# frozen_string_literal: true

require_relative "../config/environment"

networks = %w[mainnet testnet]
sleep_time = 5 # seconds
update_stats_time = 60 # seconds
@counter = 0

def get_latest_cluster_stats
  {
    mainnet: ClusterStat.by_network("mainnet").last.to_json,
    testnet: ClusterStat.by_network("testnet").last.to_json
  }
end

@last_cluster_stats = get_latest_cluster_stats

loop do
  begin
    @counter += 1
    if @counter == update_stats_time / sleep_time
      @counter = 0
      @last_cluster_stats = get_latest_cluster_stats
    end

    ftx_response = FtxClient.new.get_market
    parsed_response = JSON.parse(ftx_response.body)
    parsed_response["cluster_stats"] = @last_cluster_stats
    print parsed_response
    ActionCable.server.broadcast("sol_price_channel", parsed_response)
    sleep(sleep_time)
  rescue => e
    puts e
    puts e.backtrace
    sleep(sleep_time)
    next
  end
end
