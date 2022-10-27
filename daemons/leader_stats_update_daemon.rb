# frozen_string_literal: true

require_relative "../config/environment"

@leaders_limit = 6
@fetched_leaders_limit = 20
@mainnet = "mainnet"
@networks = [@mainnet, "testnet"].freeze
sleep_time = 2 # seconds

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
    leaders = all_leaders
    print leaders
    ActionCable.server.broadcast("leaders_channel", leaders)
    sleep(sleep_time)
  rescue => e
    puts e
    puts e.backtrace
    sleep(sleep_time)
    next
  end
end
