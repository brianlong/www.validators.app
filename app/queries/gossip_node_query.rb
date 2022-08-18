# frozen_string_literal: true

class GossipNodeQuery
  def initialize(network: "mainnet")
    @network = network
    query = <<~SQL
    (
      SELECT gossip_nodes.* FROM gossip_nodes
      LEFT OUTER JOIN validators
      ON validators.account = gossip_nodes.identity 
      AND validators.network = gossip_nodes.network
      INNER JOIN validator_ips ON validator_ips.address = gossip_nodes.ip
      INNER JOIN data_center_hosts ON data_center_hosts.id = validator_ips.data_center_host_id
      INNER JOIN data_centers ON data_centers.id = data_center_hosts.data_center_id
      WHERE gossip_nodes.network = "#{@network}"
    )
    SQL
    @base_query = GossipNode.connection.execute(query)
  end

  def call(filter: nil, limit: 500, page: 1)
    @base_query
  end
end
