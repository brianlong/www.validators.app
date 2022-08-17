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

      raise "No nodes returned by cli" unless current_nodes.any?

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

        db_node.add_validator_ip
      end

      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(500, p.payload, "Error from update_nodes", e)
    end
  end

  def set_staked_flag
    lambda do |p|
      staked_validators = Validator.joins(:validator_score_v1)
                                   .joins(:validator_ips)
                                   .where("validator_score_v1s.active_stake > 0")

      staked_ips = staked_validators.pluck("validator_ips.address")
      staked_nodes = GossipNode.where(ip: staked_ips)
      staked_nodes.update_all(staked: true)

      GossipNode.where.not(ip: staked_nodes.pluck(:ip)).update_all(staked: false)

      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(500, p.payload, "Error from set_staked_flag", e)
    end
  end
end
