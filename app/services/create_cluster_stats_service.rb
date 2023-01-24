# frozen_string_literal: true

class CreateClusterStatsService
  
  def initialize(network:, batch_uuid:)
    @network = network
    @batch_uuid = batch_uuid
  end

  def call
    validators_total = Validator.where(network: @network).active.count
    nodes_total = GossipNode.where(network: @network).active.not_staked.count
    dominant_software_version = Batch.last_scored(@network).software_version

    network_stat = ClusterStat.find_or_create_by(network: @network)

    fields_for_update = {}
    fields_for_update[:total_active_stake] = \
      validator_history_stats.total_active_stake if validator_history_stats.total_active_stake
    fields_for_update[:software_version] = dominant_software_version if dominant_software_version
    fields_for_update[:validator_count] = validators_total if validators_total
    fields_for_update[:nodes_count] = nodes_total if nodes_total
    fields_for_update[:root_distance] = \
      validator_score_stats.root_distance_stats if validator_score_stats.root_distance_stats
    fields_for_update[:vote_distance] = \
      validator_score_stats.vote_distance_stats if validator_score_stats.vote_distance_stats
    fields_for_update[:skipped_slots] = \
      validator_block_history_stats.skipped_slot_stats if validator_block_history_stats.skipped_slot_stats
    fields_for_update[:skipped_votes] = \
      vote_account_history_stats.skipped_votes_stats if vote_account_history_stats.skipped_votes_stats

    network_stat.update(fields_for_update)
  end

  private

  def validator_history_stats
    Stats::ValidatorHistory.new(@network, @batch_uuid)
  end

  def vote_account_history_stats
    Stats::VoteAccountHistory.new(@network, @batch_uuid)
  end

  def validator_block_history_stats
    Stats::ValidatorBlockHistory.new(@network, @batch_uuid)
  end

  def validator_score_stats
    @validator_score_stats ||= Stats::ValidatorScore.new(@network, @batch_uuid)
  end
end
