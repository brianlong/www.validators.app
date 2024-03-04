#frozen_string_literal: true

require File.expand_path('../../config/environment', __dir__)

destroy_after_archive = ARGV[0]&.in?(["true", "false"]) ? ARGV[0] == "true" : false

ARCHIVE_TIME = {
  mainnet: 2.months.ago,
  testnet: 2.months.ago,
  pythnet: 2.months.ago,
}.freeze

NETWORKS.each do |network|
  PingThing.archive_due_to(
    date_to: ARCHIVE_TIME[network.to_sym],
    network: network,
    destroy_after_archive: destroy_after_archive
  )
end
