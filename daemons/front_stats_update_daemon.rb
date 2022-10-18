# frozen_string_literal: true

require_relative "../config/environment"

LEADERS_LIMIT = 6
FETCHED_LEADERS_LIMIT = 20
MAINNET = 'mainnet'
NETWORKS = [MAINNET, 'testnet']

def broadcast_leaders_by_network(network)
  client = solana_client(network)
  current_slot = client.get_slot.result
  leader_accounts = client.get_slot_leaders(current_slot, FETCHED_LEADERS_LIMIT).result
  leaders = Validator.where(account: leader_accounts)
  leaders_mapped = leaders.map do |leader|
    { name: leader.name, avatar_url: leader.avatar_url }
  end
  channel = leaders_channel(network)

  print leaders_mapped
  ActionCable.server.broadcast(channel, leaders_mapped.take(LEADERS_LIMIT))
end

def solana_client(network)
  network == MAINNET ? mainnet_client : testnet_client
end

def leaders_channel(network)
  network == MAINNET ? "leaders_mainnet_channel" : "leaders_testnet_channel"
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

    NETWORKS.each do |network|
      broadcast_leaders_by_network(network)
    end
    sleep(5)
  rescue
    sleep(5)
    next
  end
end
