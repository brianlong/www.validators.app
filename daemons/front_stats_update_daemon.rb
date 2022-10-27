# frozen_string_literal: true

require_relative "../config/environment"
require_relative './concerns/front_software_versions_module.rb'

include FrontSoftwareVersionsModule

@leaders_limit = 6
@fetched_leaders_limit = 20
@mainnet = "mainnet"
@networks = [@mainnet, "testnet"].freeze
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

def all_leaders
  @networks.map do |network|
    [network, leaders_for_network(network)]
  end.to_h
end

def leaders_for_network(network)
  client = solana_client(network)
  current_slot = client.get_slot.result
  leader_accounts = client.get_slot_leaders(current_slot, @fetched_leaders_limit).result
  leaders = Validator.where(account: leader_accounts)

  leaders_data(leaders).take(@leaders_limit)
end

def leaders_data(leaders)
  leaders.map do |leader|
    { name: leader.name, avatar_url: leader.avatar_url, account: leader.account }
  end
end

def solana_client(network)
  network == @mainnet ? @mainnet_client : @testnet_client
end

@mainnet_client = SolanaRpcClient.new.mainnet_client
@testnet_client = SolanaRpcClient.new.testnet_client

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
    ftx_response = FtxClient.new.get_market
    parsed_response = JSON.parse(ftx_response.body)
    parsed_response["cluster_stats"] = @last_cluster_stats
    leaders = all_leaders

    # Broadcasts
    ActionCable.server.broadcast("front_stats_channel", parsed_response)
    broadcast_software_versions(@software_versions)
    ActionCable.server.broadcast("leaders_channel", leaders)

    sleep(sleep_time)
  rescue => e
    puts e
    puts e.backtrace
    sleep(sleep_time)
    next
  end
end
