# frozen_string_literal: true

require 'test_helper'

# FeedZoneLogicTest
class FeedZoneLogicTest < ActiveSupport::TestCase
  include FeedZoneLogic

  def setup
    # Create our initial payload with the input values
    @initial_payload = {
      network: 'testnet',
      batch_uuid: '1234'
    }
  end

  test 'set_this_batch' do
    p = Pipeline.new(200, @initial_payload)
                .then(&set_this_batch)

    assert_equal 200, p.code
    assert_equal 'testnet', p.payload[:this_batch].network
    assert_equal '1234', p.payload[:this_batch].uuid
  end

  test 'set_previous_batch' do
    # With the initial_payload, the prev_batch will be empty.
    p = Pipeline.new(200, @initial_payload)
                .then(&set_this_batch)
                .then(&set_previous_batch)

    assert_equal 200, p.code
    assert_nil p.payload[:prev_batch]

    # With the second batch, the prev_batch will be populated.
    p = Pipeline.new(200, { network: 'testnet', batch_uuid: '5678' })
                .then(&set_this_batch)
                .then(&set_previous_batch)

    assert_equal 200, p.code
    assert_equal '1234', p.payload[:prev_batch].uuid
  end

  test 'set_feed_zone' do
    p = Pipeline.new(200, @initial_payload)
                .then(&set_this_batch)
                .then(&set_previous_batch)
                .then(&set_feed_zone)

    assert_equal '1234', p.payload[:feed_zone].batch_uuid
  end

  test 'set_this_epoch' do
    p = Pipeline.new(200, @initial_payload)
                .then(&set_this_batch)
                .then(&set_previous_batch)
                .then(&set_feed_zone)
                .then(&set_this_epoch)

    assert_equal '1234', p.payload[:this_epoch].batch_uuid
  end

  test 'compile_feed_zone_payload' do
    p = Pipeline.new(200, @initial_payload)
                .then(&set_this_batch)
                .then(&set_previous_batch)
                .then(&set_feed_zone)
                .then(&set_this_epoch)
                .then(&compile_feed_zone_payload)

    assert_equal 200, p.code
    assert_equal 1, p.payload[:feed_zone_payload].size
    assert_equal '1234', p.payload[:feed_zone_payload].first['batch_uuid']
  end

  test 'save_feed_zone' do
    p = Pipeline.new(200, @initial_payload)
                .then(&set_this_batch)
                .then(&set_previous_batch)
                .then(&set_feed_zone)
                .then(&set_this_epoch)
                .then(&compile_feed_zone_payload)
                .then(&save_feed_zone)

    # Pull the feed_zone record from the DB so we can compare it to the pipeline
    feed_zone = FeedZone.where(@initial_payload).first
    assert_equal 'testnet', feed_zone.network
    assert_equal '1234', feed_zone.batch_uuid
    assert_equal Batch.first.created_at, feed_zone.batch_created_at
    assert_equal 1, feed_zone.payload_version
    assert_equal p.payload[:feed_zone].batch_uuid, feed_zone.batch_uuid
    assert_equal p.payload[:feed_zone].payload.first['account'], \
                 feed_zone.payload.first['account']
  end
end
