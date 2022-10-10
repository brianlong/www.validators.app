# frozen_string_literal: true

module StakeStatsLogic

  def update_total_active_stake
    lambda do |p|
      network = p.payload[:network]
      batch_uuid = p.payload[:batch_uuid]
      validator_history_stats = Stats::ValidatorHistory.new(network, batch_uuid)
      total_active_stake = validator_history_stats.total_active_stake

      ClusterStat.create(network: network, total_active_stake: total_active_stake)
    end
  end
end
