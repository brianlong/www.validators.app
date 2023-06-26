# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)

network = ARGV[0] || "mainnet"

return puts("please provide correct network parameter") unless NETWORKS.include?(network)

LOG_PATH = Rails.root.join("log", "backfill_validator_groups_#{network}.log")

VoteAccount.where(network: network).find_each do |vote_account|
  puts "checking vote account #{vote_account.account}"
  CheckGroupValidatorAssignmentService.new(vote_account_id: vote_account.id, log_path: LOG_PATH).call
end
