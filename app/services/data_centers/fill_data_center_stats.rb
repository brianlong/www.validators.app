# frozen_string_literal: true

class DataCenters::FillDataCenterStats
  def initialize(network: "mainnet", batch_uuid: nil)
    @network = network
    @batch_uuid = batch_uuid || Batch.last_scored(@network)&.uuid
  end

  def call
    distances = distances_by_data_center_id

    DataCenter.includes(:validators, :gossip_nodes).all.each do |dc|
      validators_count = dc.validators.where(network: @network).size
      active_validators_stake = dc.validators.joins(:validator_score_v1).where(network: @network).active.sum(:active_stake)
      active_validators_count = dc.validators.where(network: @network).active.size
      nodes_count = dc.gossip_nodes.where(network: @network, staked: false).size
      active_nodes_count = dc.gossip_nodes.where(network: @network, staked: false).active.size

      stats = dc.data_center_stats.find_or_create_by(network: @network)
      stats.validators_count = validators_count
      stats.active_validators_stake = active_validators_stake
      stats.active_validators_count = active_validators_count
      stats.gossip_nodes_count = nodes_count
      stats.active_gossip_nodes_count = active_nodes_count

      if @batch_uuid
        dc_distances = distances[dc.id] || []
        stats.root_distance = distance_stats_for(dc_distances.map(&:first))
        stats.vote_distance = distance_stats_for(dc_distances.map(&:second))
      end

      stats.save if stats.changed?
    end
  end

  private

  # One query for the whole network+batch: [data_center_id, root_distance, vote_distance]
  # grouped by data_center_id, so we avoid an extra pair of queries per data center.
  def distances_by_data_center_id
    return {} unless @batch_uuid

    ValidatorHistory.for_batch(@network, @batch_uuid)
                    .joins(validator: :data_center)
                    .pluck("data_centers.id", :root_distance, :vote_distance)
                    .group_by { |data_center_id, _root_distance, _vote_distance| data_center_id }
                    .transform_values { |rows| rows.map { |_id, root_distance, vote_distance| [root_distance, vote_distance] } }
  end

  def distance_stats_for(values)
    values = values.compact
    return nil if values.empty?

    { min: values.min, max: values.max, median: values.median, average: values.average }
  end
end
