# frozen_string_literal: true

class GossipNodeQuery
  def initialize(network: "mainnet")
    @network = network
    @query = <<~SQL
      SELECT #{query_fields} FROM gossip_nodes
      LEFT OUTER JOIN validators
      ON validators.account = gossip_nodes.identity 
      AND validators.network = gossip_nodes.network
      LEFT OUTER JOIN validator_ips ON validator_ips.address = gossip_nodes.ip
      LEFT OUTER JOIN data_center_hosts ON data_center_hosts.id = validator_ips.data_center_host_id
      LEFT OUTER JOIN data_centers ON data_centers.id = data_center_hosts.data_center_id
      WHERE gossip_nodes.network = :network
    SQL
  end

  def call(staked: nil, limit: 500, page: 1)
    filter_query = staked ? "AND gossip_nodes.staked = :staked" : nil
    pagination_query = "LIMIT :limit OFFSET :offset"
    query_params = {
      network: @network,
      limit: limit,
      offset: (page - 1) * limit,
      staked: staked
    }
    sanitized_query = ApplicationRecord.sanitize_sql([[@query, filter_query, pagination_query].join(" "), query_params])

    ActiveRecord::Base.connection.exec_query(sanitized_query)
  end

  private

  def query_fields
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
end
