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
    # current_slot = client.get_slot.result
    # leader_accounts = client.get_slot_leaders(current_slot, LEADERS_LIMIT).result
    # leaders = Validator.where(account: leader_accounts, network: network)
    #                    .select(:name, :account, :avatar_url)
    # leaders = leaders_data(leaders)
    #
    # {
    #   current_leader: leaders.shift,
    #   next_leaders: leaders
    # }

    leader_account = client.get_slot_leader.result
    leader = Validator.where(account: leader_account, network: network).select(:name, :account, :avatar_url)
    leader = leaders_data(leader)
    {
      current_leader: leader.first,
      next_leaders: []
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
