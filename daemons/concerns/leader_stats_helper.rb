# frozen_string_literal: true

require_relative './front_stats_constants.rb'

module LeaderStatsHelper
  include FrontStatsConstants

  VALIDATOR_FIELDS_FOR_LEADER = %w[name account avatar_url].freeze
  DC_FIELDS_FOR_LEADER = %w[location_latitude location_longitude country_iso_code].freeze

  def all_leaders
    FrontStatsConstants::NETWORKS.map do |network|
      [network, leaders_for_network(network)]
    end.to_h
  end

  private

  def leaders_for_network(network)
    client = solana_client(network)

    current_slot = client.get_slot.result
    leaders_accounts = client.get_slot_leaders(current_slot, FrontStatsConstants::LEADERS_LIMIT).result

    leaders_data = Validator.where(account: leaders_accounts, network: network)
                            .left_outer_joins(:data_center)
                            .select(full_fields_for_leader)
                            .limit(3)
                            .sort_by{ |v| leaders_accounts.index(v.account) }
    leaders = leaders_data(leaders_data)
    current_leader = leaders.shift

    {
      current_leader: current_leader,
      next_leaders: leaders
    }
  end

  def full_fields_for_leader
    validator_fields = VALIDATOR_FIELDS_FOR_LEADER.map{ |field| "validators." + field }
    dc_fields = DC_FIELDS_FOR_LEADER.map{ |field| "data_centers." + field }

    (validator_fields + dc_fields).join(", ")
  end

  def leaders_data(leaders)
    leaders.map do |leader|
      leader.attributes
    end
  end

  def solana_client(network)
    network == "mainnet" ? mainnet_client : testnet_client
  end

  def mainnet_client
    SolanaRpcClient.new.mainnet_client
  end

  def testnet_client
    SolanaRpcClient.new.testnet_client
  end
end
