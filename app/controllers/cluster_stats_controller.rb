# frozen_string_literal: true

# PublicController
class ClusterStatsController < ApplicationController
  def index
    network = params[:network]

    @stats = gather_stats_for(network)
    @batch = Batch.find_by(uuid: @stats[:batch_uuid])
    @this_epoch = EpochHistory.where(network: network, batch_uuid: @batch.uuid).first&.epoch
    @validators_count = Validator.where(network: network).scorable.count
    validator_history_stats = Stats::ValidatorHistory.new(
      network,
      @stats[:batch_uuid]
    )
    @total_active_stake = validator_history_stats.total_active_stake
  end

  private

  def gather_stats_for(network)
    Report.where(name: 'report_cluster_stats', network: network).last.payload.deep_symbolize_keys
  end
end
