# frozen_string_literal: true

require_relative "../config/environment"

LEADERS_LIMIT = 6
FETCHED_LEADERS_LIMIT = 20
MAINNET = "mainnet"
NETWORKS = [MAINNET, "testnet"].freeze

def all_leaders
  NETWORKS.map do |network|
    [network, leaders_for_network(network)]
  end.to_h
end

def leaders_for_network(network)
  client = solana_client(network)
  current_slot = client.get_slot.result
  leader_accounts = client.get_slot_leaders(current_slot, FETCHED_LEADERS_LIMIT).result
  leaders = Validator.where(account: leader_accounts)

  leaders_data(leaders).take(LEADERS_LIMIT)
end

def leaders_data(leaders)
  leaders.map do |leader|
    { name: leader.name, avatar_url: leader.avatar_url, account: leader.account }
  end
end

def solana_client(network)
  network == MAINNET ? mainnet_client : testnet_client
end

def mainnet_client
  @mainnet_client ||= SolanaRpcClient.new.mainnet_client
end

def testnet_client
  @testnet_client ||= SolanaRpcClient.new.testnet_client
end

loop do
  begin
    ftx_response = FtxClient.new.get_market
    parsed_response = JSON.parse(ftx_response.body)
    print parsed_response
    ActionCable.server.broadcast("sol_price_channel", parsed_response)

    leaders = all_leaders
    print leaders
    ActionCable.server.broadcast("leaders_channel", leaders)
    sleep(5)
  rescue
    sleep(5)
    next
  end
end
