# frozen_string_literal: true

# Logic to compile data for the feed_zone
module FeedZoneLogic
  include PipelineLogic
  PAYLOAD_VERSION = 1

  # Payload starts with :network & :batch_uuid
  def set_this_batch
    lambda do |p|
      this_batch = Batch.where(
        network: p.payload[:network],
        uuid: p.payload[:batch_uuid]
      ).first

      if this_batch.nil?
        raise "No batch: #{p.payload[:network]}, #{p.payload[:batch_uuid]}"
      end

      Pipeline.new(200, p.payload.merge(this_batch: this_batch))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from set_this_batch', e)
    end
  end

  def set_previous_batch
    lambda do |p|
      prev_batch = Batch.where(
        ['network = ? AND created_at < ?',
         p.payload[:network],
         p.payload[:this_batch].created_at]
      ).first
      # Note: It is acceptable for prev_batch to be nil.

      Pipeline.new(200, p.payload.merge(prev_batch: prev_batch))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from set_previous_batch', e)
    end
  end

  def set_feed_zone
    lambda do |p|
      feed_zone = FeedZone.create_or_find_by(
        network: p.payload[:network],
        batch_uuid: p.payload[:batch_uuid]
      )

      Pipeline.new(200, p.payload.merge(feed_zone: feed_zone))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from set_previous_batch', e)
    end
  end

  def set_this_epoch
    lambda do |p|
      this_epoch = EpochHistory.where(
        network: p.payload[:network],
        batch_uuid: p.payload[:batch_uuid]
      ).first

      Pipeline.new(200, p.payload.merge(this_epoch: this_epoch))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from set_previous_batch', e)
    end
  end

  # Loop through all of the validators for this batch and complile the data.
  def compile_feed_zone_payload
    lambda do |p|
      p.payload[:feed_zone].payload_version = PAYLOAD_VERSION

      feed_zone_payload = []

      ValidatorHistory.where(
        network: p.payload[:network], batch_uuid: p.payload[:batch_uuid]
      ).each do |validator|
        tmp = {}

        tmp['network'] = p.payload[:network]
        tmp['batch_uuid'] = p.payload[:batch_uuid]

        # validator_histories table
        tmp['account'] = validator.account
        tmp['delinquent'] = validator.delinquent
        tmp['vote_account'] = validator.vote_account
        tmp['commission'] = validator.commission

        # this_epoch
        tmp['epoch'] = p.payload[:this_epoch].epoch
        tmp['epoch_current_slot'] = p.payload[:this_epoch].current_slot

        # TODO: Compile more data here.

        # Append tmp
        feed_zone_payload << tmp
      end

      Pipeline.new(200, p.payload.merge(feed_zone_payload: feed_zone_payload))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from compile_feed_zone_payload', e)
    end
  end

  def save_feed_zone
    lambda do |p|
      p.payload[:feed_zone].payload_version = PAYLOAD_VERSION
      p.payload[:feed_zone].batch_created_at = p.payload[:this_batch].created_at
      p.payload[:feed_zone].payload = p.payload[:feed_zone_payload]
      p.payload[:feed_zone].save!

      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from compile_feed_zone_payload', e)
    end
  end
end
