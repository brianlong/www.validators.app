# frozen_string_literal: true

class DataCenters::FillDataCenterStats
  def initialize(network: "mainnet")
    @network = network
  end

  def call
    DataCenter.includes(:validators, :gossip_nodes).all.each do |dc|
      validators_count = dc.validators.where(network: @network).size
      active_validators_count = dc.validators.where(network: @network).active.size
      nodes_count = dc.gossip_nodes.where(network: @network, staked: false).size
      active_nodes_count = dc.gossip_nodes.where(network: @network, staked: false).active.size

      stats = dc.data_center_stats.find_or_create_by(network: @network)
      stats.validators_count = validators_count
      stats.active_validators_count = active_validators_count
      stats.gossip_nodes_count = nodes_count
      stats.active_gossip_nodes_count = active_nodes_count

      stats.save if stats.changed?
    end
  end
end
