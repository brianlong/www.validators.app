# frozen_string_literal: true

# PublicController
class ClusterStatsController < ApplicationController
  def index
    @stats = gather_stats_for(params[:network])
    @batch = Batch.find_by(uuid: @stats[:batch_uuid])
    @this_epoch = EpochHistory.where(network: params[:network], batch_uuid: @batch.uuid).first&.epoch
    @validators_count = Validator.where(network: params[:network]).scorable.count
  end

  private

  def gather_stats_for(network)
    batch = Batch.last_scored(network)

    return {} unless batch

    vah_stats = Stats::VoteAccountHistory.new(network, batch.uuid)
    vbh_stats = Stats::ValidatorBlockHistory.new(network, batch.uuid)
    vs_stats  = Stats::ValidatorScore.new(network, batch.uuid)
    software_report = Report.where(
      network: params[:network],
      name: 'report_software_versions'
    ).last&.payload

    {
      top_staked_validators: vs_stats.top_staked_validators || [],
      total_stake: vs_stats.total_stake,
      top_skipped_vote_validators: vah_stats.top_skipped_vote_percent || [],
      top_root_distance_validators: vs_stats.top_root_distance_averages_validators || [],
      top_vote_distance_validators: vs_stats.top_vote_distance_averages_validators || [],
      top_skipped_slot_validators: vbh_stats.top_skipped_slot_percent || [],
      skipped_votes_percent: vah_stats.skipped_votes_stats,
      skipped_votes_percent_moving_average: vah_stats.skipped_vote_moving_average_stats,
      root_distance: vs_stats.root_distance_stats,
      vote_distance: vs_stats.vote_distance_stats,
      skipped_slots: vbh_stats.skipped_slot_stats,
      software_version: software_report,
      batch_uuid: batch.uuid
    }
  end
end
