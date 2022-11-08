# frozen_string_literal: true

module LeaderStatsHelper
  LEADERS_LIMIT = 9
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

    current_slot = client.get_slot.result
    leaders_accounts = client.get_slot_leaders(current_slot, LEADERS_LIMIT).result

    leaders_data = Validator.where(account: leaders_accounts, network: network)
                            .select(:name, :account, :avatar_url)
                            .limit(3)
                            .sort_by{ |v| leaders_accounts.index(v.account) }
    leaders = leaders_data(leaders_data)
    current_leader = leaders.shift

    {
      current_leader: current_leader,
      next_leaders: leaders
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
