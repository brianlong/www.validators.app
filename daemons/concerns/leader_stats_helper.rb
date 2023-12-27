# frozen_string_literal: true

require_relative './front_stats_constants.rb'

module LeaderStatsHelper
  include FrontStatsConstants

  def leaders_for_network(network)
    client = SolanaRpcClient.new.network_client(network)

    current_slot = client.get_slot.result
    leaders_accounts = client.get_slot_leaders(current_slot, FrontStatsConstants::LEADERS_LIMIT).result

    leaders_data = Validator.where(account: leaders_accounts, network: network)
                            .with_attached_avatar
                            .left_outer_joins(:data_center)
                            .select(fields_for_leader)
                            .limit(3)
                            .sort_by{ |v| leaders_accounts.index(v.account) }

    leaders = leaders_data.map do |leader|
      leader.attributes.merge(avatar_file_url: leader.avatar_file_url)
    end

    current_leader = leaders.shift

    {
      current_leader: current_leader,
      next_leaders: leaders
    }
  end

  private

  def fields_for_leader
    validator_fields = FrontStatsConstants::VALIDATOR_FIELDS_FOR_LEADER.map{ |field| "validators." + field }
    dc_fields = FrontStatsConstants::DC_FIELDS_FOR_LEADER.map{ |field| "data_centers." + field }

    (validator_fields + dc_fields).join(", ")
  end
end
