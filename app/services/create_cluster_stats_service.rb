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

    last_epochs = last_epochs(EPOCHS_TO_CALCULATE)
    if last_epochs.count > 0
      epochs_duration = (last_epochs.second.created_at - last_epochs.first.created_at) / 60 / 60 / 24
      epochs_average_roi = last_epochs(EPOCHS_TO_CALCULATE).map do |epoch|
        if epoch.total_rewards && epoch.total_active_stake
          (epoch.total_rewards / epoch.total_active_stake.to_f) * 100
        end
      end.compact.average

      epochs_annual_roi = (365 / epochs_duration) * epochs_average_roi
    end
    epochs_annual_roi ||= 0
    network_stat = ClusterStat.find_or_create_by(network: @network)

    fields_for_update = {}
    fields_for_update[:roi] = epochs_annual_roi
    fields_for_update[:total_active_stake] = \
      validator_history_stats.total_active_stake if \
      validator_history_stats.total_active_stake && \
      validator_history_stats.total_active_stake > 0
    fields_for_update[:software_version] = dominant_software_version if dominant_software_version
    fields_for_update[:validator_count] = validators_total if validators_total && validators_total > 0
    fields_for_update[:nodes_count] = nodes_total if nodes_total && nodes_total > 0
    fields_for_update[:root_distance] = \
      validator_score_stats.root_distance_stats if hash_valid?(validator_score_stats.root_distance_stats)
    fields_for_update[:vote_distance] = \
      validator_score_stats.vote_distance_stats if hash_valid?(validator_score_stats.vote_distance_stats)
    fields_for_update[:skipped_slots] = \
      validator_block_history_stats.skipped_slot_stats if hash_valid?(validator_block_history_stats.skipped_slot_stats)
    fields_for_update[:skipped_votes] = \
      vote_account_history_stats.skipped_votes_stats if hash_valid?(vote_account_history_stats.skipped_votes_stats)

    network_stat.update(fields_for_update)
  end

  private

  def last_epochs(num)
    @last_epochs ||= EpochWallClock.where(network: @network)
                                   .where.not(ending_slot: nil)
                                   .last(num)
  end
  
  def hash_valid? hash
    hash.map{|k, v| return false unless v}
    true
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
