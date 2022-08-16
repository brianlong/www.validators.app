# frozen_string_literal: true

module GossipNodeLogic
  include PipelineLogic
  include SolanaLogic #for solana_client_request

  def get_nodes
    lambda do |p|
      current_nodes = cli_request(
        "gossip",
        p.payload[:config_urls]
      )

      Pipeline.new(200, p.payload.merge(current_nodes: current_nodes))
    rescue StandardError => e
      Pipeline.new(500, p.payload, "Error from get_nodes", e)
    end
  end

  def update_nodes
    lambda do |p|
      p.payload[:current_nodes].each do |node|
        db_node = GossipNode.find_or_create_by(
          network: p.payload[:network],
          identity: node["identityPubkey"]
        )

        db_node.ip = node["ipAddress"]
        db_node.tpu_port = node["tpuPort"]
        db_node.gossip_port = node["gossipPort"]
        db_node.version = node["version"]

        db_node.save if db_node.changed?
      end

      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(500, p.payload, "Error from connect_nodes_to_validators", e)
    end
  end
end
