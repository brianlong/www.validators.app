# frozen_string_literal: true
#
# RAILS_ENV=production bundle exec rails r script/validator_ips/remove_without_validator_or_gossip_node.rb

require_relative '../../config/environment'

ValidatorIp.where.missing(:validator, :gossip_node).destroy_all

