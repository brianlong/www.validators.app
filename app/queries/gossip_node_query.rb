# frozen_string_literal: true

class GossipNodeQuery

  def initialize(network: "mainnet")
    @network = network
    @query = GossipNode.select(query_fields)
                       .joins(
                         "LEFT OUTER JOIN validators 
                          ON validators.account = gossip_nodes.identity 
                          AND validators.network = gossip_nodes.network"
                       ).left_outer_joins(:data_center)
                       .where(network: @network)
  end

  def call(staked: nil, per: 100, page: 1)
    if staked
      @query = @query.where(staked: staked)
    end
    @query.page(page).per(per)
  end

  def self.query_fields_compact
    query_fields.split(", ").map{ |q| q.split(".")[1]}.uniq
  end

  private

  def self.query_fields
    gossip_node_fields = GossipNode::FIELDS_FOR_API.map do |field|
      "gossip_nodes.#{field}"
    end.join(", ")

    val_fields_reduced = Validator::FIELDS_FOR_API.reject{ |f| %i[account updated_at created_at network].include? f }

    validator_fields = val_fields_reduced.map do |field|
      "validators.#{field}"
    end.join(", ")

    data_center_fields = DataCenter::FIELDS_FOR_API.map do |field|
      "data_centers.#{field}"
    end.join(", ")

    [gossip_node_fields, validator_fields, data_center_fields].join(", ")
  end

  def query_fields
    self.class.query_fields
  end
end
