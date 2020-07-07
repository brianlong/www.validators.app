# frozen_string_literal: true

require 'test_helper'

class FeedZoneTest < ActiveSupport::TestCase
  test 'create object' do
    feed_zone = FeedZone.create(
      network: 'testnet',
      batch_uuid: SecureRandom.uuid,
      payload: { 'ping' => 'pong' },
      payload_version: 1
    )
    assert_equal 'pong', feed_zone.payload['ping']
  end
end
