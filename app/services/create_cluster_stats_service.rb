# frozen_string_literal: true

class CreateClusterStatsService
  EPOCHS_TO_CALCULATE = 3
  
  def initialize(network:, batch_uuid:)
    @network = network
    @batch_uuid = batch_uuid
  end

  def call
    validators_total = Validator.where(network: @network).active.count
    nodes_total = GossipNode.where(network: @network).active.not_staked.count
    dominant_software_version = Batch.last_scored(@network).software_version

    epochs_roi = last_epochs(EPOCHS_TO_CALCULATE).map do |epoch|
      if epoch.total_rewards && epoch.total_active_stake
        (epoch.total_rewards / epoch.total_active_stake.to_f) * 100
      end
    end.compact

    network_stat = ClusterStat.find_or_create_by(network: @network)
    network_stat.update(
      total_active_stake: validator_history_stats.total_active_stake,
      software_version: dominant_software_version,
      validator_count: validators_total,
      nodes_count: nodes_total,
      root_distance: validator_score_stats.root_distance_stats,
      vote_distance: validator_score_stats.vote_distance_stats,
      skipped_slots: validator_block_history_stats.skipped_slot_stats,
      skipped_votes: vote_account_history_stats.skipped_votes_stats,
      roi: epochs_roi.average.round(2)
    )
  end

  private

  def last_epochs(num)
    @last_epochs ||= EpochWallClock.where(network: @network)
                                   .where.not(ending_slot: nil)
                                   .last(num)
  end

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
