# frozen_string_literal: true

class CreateClusterStatsService
  
  def initialize(network:, batch_uuid:)
    @network = network
    @batch_uuid = batch_uuid
  end

  def call
    validator_history_stats = Stats::ValidatorHistory.new(@network, @batch_uuid)
    total_active_stake = validator_history_stats.total_active_stake

    validators_total = Validator.where(network: @network).active.count
    nodes_total = GossipNode.where(network: @network).active.not_staked.count
    dominant_software_version = Batch.last_scored(@network).software_version

    network_stat = ClusterStat.find_or_create_by(network: @network)
    network_stat.update(
      total_active_stake: total_active_stake,
      software_version: dominant_software_version,
      validator_count: validators_total,
      nodes_count: nodes_total,
      root_distance: report[:root_distance],
      vote_distance: report[:vote_distance],
      skipped_slots: report[:skipped_slots],
      skipped_votes: report[:skipped_votes_percent]
    )
  end

  private

  def report
    @report ||= Report.where(name: "report_cluster_stats", network: @network).last.payload.deep_symbolize_keys
  end
end
