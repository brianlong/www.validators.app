# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/bootstrap_feed_zone.rb
require File.expand_path('../config/environment', __dir__)
require 'solana_logic'

include FeedZoneLogic

%w[testnet mainnet].each do |network|
  Batch.where(network: network).each do |batch|
    FeedZoneWorker.set(queue: 'low_priority')
                  .perform_async(
                    network: network,
                    batch_uuid: batch.uuid
                  )
  end
end
