# frozen_string_literal: true

class DataCenters::FillDataCenterStats
  def initialize(network: "mainnet", batch_uuid: nil)
    @network = network
    @batch_uuid = batch_uuid || Batch.last_scored(@network)&.uuid
  end

  def call
    validators_counts = validators_counts_by_data_center_id
    active_validators_counts = active_validators_counts_by_data_center_id
    active_validators_stakes = active_validators_stakes_by_data_center_id
    nodes_counts = nodes_counts_by_data_center_id(active: false)
    active_nodes_counts = nodes_counts_by_data_center_id(active: true)
    distances = distances_by_data_center_id

    DataCenter.find_each do |dc|
      stats = dc.data_center_stats.find_or_create_by(network: @network)
      stats.validators_count = validators_counts[dc.id] || 0
      stats.active_validators_stake = active_validators_stakes[dc.id] || 0
      stats.active_validators_count = active_validators_counts[dc.id] || 0
      stats.gossip_nodes_count = nodes_counts[dc.id] || 0
      stats.active_gossip_nodes_count = active_nodes_counts[dc.id] || 0

      if @batch_uuid
        dc_distances = distances[dc.id] || []
        stats.root_distance = distance_stats_for(dc_distances.map(&:first))
        stats.vote_distance = distance_stats_for(dc_distances.map(&:second))
      end

      stats.save if stats.changed?
    end
  end

  private

  # Grouped queries below replace what used to be ~6 queries per DataCenter
  # (one query total per metric, instead of one per DataCenter).
  def validators_counts_by_data_center_id
    Validator.joins(:data_center)
             .where(network: @network)
             .group("data_centers.id")
             .count
  end

  def active_validators_counts_by_data_center_id
    Validator.joins(:data_center)
             .where(network: @network)
             .active
             .group("data_centers.id")
             .count
  end

  def active_validators_stakes_by_data_center_id
    Validator.joins(:data_center, :validator_score_v1)
             .where(network: @network)
             .active
             .group("data_centers.id")
             .sum(:active_stake)
  end

  def nodes_counts_by_data_center_id(active:)
    scope = GossipNode.joins(:data_center_host).where(network: @network, staked: false)
    scope = scope.active if active
    scope.group("data_center_hosts.data_center_id").count
  end

  # One query for the whole network+batch: [data_center_id, root_distance, vote_distance]
  # grouped by data_center_id, so we avoid an extra pair of queries per data center.
  def distances_by_data_center_id
    return {} unless @batch_uuid

    ValidatorHistory.for_batch(@network, @batch_uuid)
                    .where(delinquent: false)
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
