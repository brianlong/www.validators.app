# frozen_string_literal: true

# FeedZoneWorker.perform_async(
#   network: 'mainnet',
#   batch_uuid: '65c9083f-8f53-4873-a9f8-8f782e276d30'
# )
class FeedZoneWorker
  include Sidekiq::Worker
  include FeedZoneLogic

  def perform(args = {})
    payload = {
      network: args['network'],
      batch_uuid: args['batch_uuid']
    }

    _p = Pipeline.new(200, payload)
                 .then(&set_this_batch)
                 .then(&set_previous_batch)
                 .then(&set_feed_zone)
                 .then(&set_this_epoch)
                 .then(&compile_feed_zone_payload)
                 .then(&save_feed_zone)
  end
end
