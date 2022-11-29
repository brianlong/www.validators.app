# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)

include GossipNodeLogic

NETWORKS.each do |network|
  logger = Logger.new("#{Rails.root}/log/gossip_nodes_#{network}.log")

  payload = {
    config_urls: NETWORK_URLS[network],
    network: network
  }

  p = Pipeline.new(200, payload)
              .then(&get_nodes)
              .then(&update_nodes)
              .then(&set_inactive_nodes_status)
              .then(&set_staked_flag)

  logger.info "Finished at #{DateTime.now} with status #{p.code}"

  if p.errors
    logger.error p.errors.message
    p.errors.backtrace.each do |line|
      logger.error line
    end
  end
end
