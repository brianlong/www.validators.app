# frozen_string_literal: true

module GossipNodeLogic
  include PipelineLogic
  include SolanaRequestsLogic

  def get_nodes
    lambda do |p|
      current_nodes = cli_request("gossip", p.payload[:config_urls])

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
          account: node["identityPubkey"]
        )

        db_node.ip = node["ipAddress"]
        db_node.tpu_port = node["tpuPort"]
        db_node.gossip_port = node["gossipPort"]
        db_node.software_version = node["version"]
        db_node.is_active = true

        db_node.save if db_node.changed?

        db_node.add_validator_ip
      end

      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(500, p.payload, "Error from update_nodes", e)
    end
  end

  def set_inactive_nodes_status
    lambda do |p|
      active_nodes_identities = p.payload[:current_nodes]&.map { |cn| cn["identityPubkey"] }
      GossipNode.where(network: p.payload[:network]).each do |gn|
        unless active_nodes_identities&.include? gn.account
          gn.is_active = false
          gn.save if gn.will_save_change_to_attribute?(:is_active)
        end
      end
      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(500, p.payload, "Error from set_inactive_nodes_status", e)
    end
  end

  def set_staked_flag
    lambda do |p|
      staked_validators = Validator.joins(:validator_score_v1)
                                   .includes(:validator_ip_active)
                                   .where("validator_score_v1s.active_stake > 0")
                                   .where(network: p.payload[:network])

      staked_accounts = staked_validators.pluck("account")
      staked_nodes = GossipNode.where(account: staked_accounts, network: p.payload[:network])
      staked_nodes.update_all(staked: true)

      GossipNode.where(network: p.payload[:network])
                .where.not(account: staked_nodes.pluck(:account))
                .update_all(staked: false)

      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(500, p.payload, "Error from set_staked_flag", e)
    end
  end
end
