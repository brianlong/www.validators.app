# frozen_string_literal: true

class GossipNodeQuery
  attr_reader :query_fields

  def initialize(network: "mainnet")
    @network = network
    @query_fields = query_fields
    @query = GossipNode.select(query_fields)
                       .joins(
                         "LEFT OUTER JOIN validators
                          ON validators.account = gossip_nodes.account
                          AND validators.network = gossip_nodes.network"
                       ).left_outer_joins(:data_center)
                       .where(network: @network)
                       .active
  end

  def call(staked: nil, per: 100, page: 1)
    unless staked.nil?
      @query = @query.where(staked: staked)
    end

    @query.page(page).per(per)
  end

  def query_fields
    gossip_node_fields = GossipNode::API_FIELDS.map do |field|
      "gossip_nodes.#{field}"
    end.join(", ")

    validator_fields = Validator::FIELDS_FOR_GOSSIP_NODES.map do |field|
      "validators.#{field}"
    end.join(", ")

    data_center_fields = DataCenter::FIELDS_FOR_GOSSIP_NODES.map do |field|
      "data_centers.#{field}"
    end.join(", ")

    [gossip_node_fields, validator_fields, data_center_fields].join(", ")
  end
end
