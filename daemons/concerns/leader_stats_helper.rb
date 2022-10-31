# frozen_string_literal: true

module LeaderStatsHelper
  LEADERS_LIMIT = 12
  MAINNET = "mainnet"
  NETWORKS = [MAINNET, "testnet"].freeze

  def all_leaders
    NETWORKS.map do |network|
      [network, leaders_for_network(network)]
    end.to_h
  end

  private

  def leaders_for_network(network)
    client = solana_client(network)
    query_fields = "gossip_nodes.account", "validators.name", "validators.avatar_url"

    current_leader_account = client.get_slot_leader.result
    current_leader = GossipNode.select(query_fields)
                               .joins("LEFT OUTER JOIN validators
                                       ON validators.account = gossip_nodes.account
                                       AND validators.network = gossip_nodes.network"
                               ).where(account: current_leader_account, network: network)


    current_slot = client.get_slot.result
    next_leader_accounts = client.get_slot_leaders(current_slot, LEADERS_LIMIT).result
    next_leaders = GossipNode.select(query_fields)
                               .joins("LEFT OUTER JOIN validators
                                       ON validators.account = gossip_nodes.account
                                       AND validators.network = gossip_nodes.network"
                               ).where(account: next_leader_accounts, network: network)


    {
      current_leader: leaders_data(current_leader).first,
      next_leaders: leaders_data(next_leaders)
    }
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
    SolanaRpcClient.new.mainnet_client
  end

  def testnet_client
    SolanaRpcClient.new.testnet_client
  end
end
