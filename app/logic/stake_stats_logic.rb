# frozen_string_literal: true

module StakeStatsLogic

  def update_total_active_stake
    lambda do |p|
      network = p.payload[:network]
      validator_history_stats = Stats::ValidatorHistory.new(
        network,
        report_stats[:batch_uuid]
      )
      total_active_stake = validator_history_stats.total_active_stake

      ClusterStat.create(network: network, total_active_stake: total_active_stake)
    end
  end

  private

  def report_stats
    Report.where(name: "report_cluster_stats", network: network).last.payload.deep_symbolize_keys
  end
end
