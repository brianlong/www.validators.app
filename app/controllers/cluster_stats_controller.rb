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

    vah_query = VoteAccountHistoryQuery.new(network, batch.uuid)
    vbh_query = ValidatorBlockHistoryQuery.new(network, batch.uuid)
    vs_query = ValidatorScoreQuery.new(network, batch.uuid)
    software_report = Report.where(
      network: params[:network],
      name: 'report_software_versions'
    ).last&.payload

    {
      top_staked_validators:
        vs_query.top_staked_validators,
      top_skipped_vote_validators:
        vah_query.top_skipped_vote_percent,
      top_root_distance_validators:
        vs_query.top_root_distance_averages_validators,
      top_vote_distance_validators:
        vs_query.top_vote_distance_averages_validators,
      top_skipped_slot_validators:
        vbh_query.top_skipped_slot_percent,
      skipped_votes_percent:
        vah_query.skipped_votes_stats,
      skipped_votes_percent_moving_average:
        vah_query.skipped_vote_moving_average_stats,
      root_distance:
        vs_query.root_distance_stats,
      vote_distance:
        vs_query.vote_distance_stats,
      skipped_slots:
        vbh_query.skipped_slot_stats,
      software_version: software_report,
      batch_uuid: batch.uuid
    }
  end
end
