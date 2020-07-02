# frozen_string_literal: true

require 'test_helper'

# SolanaLogicTest
class SolanaLogicTest < ActiveSupport::TestCase
  include SolanaLogic

  def setup
    # Create our initial payload with the input values
    @initial_payload = {
      config_url: Rails.application.credentials.solana[:testnet_url],
      network: 'testnet'
    }
  end

  test 'batch_set' do
    p = Pipeline.new(200, @initial_payload)
                .then(&batch_set)
    assert_not_nil p[:payload][:batch_uuid]
    assert p[:payload][:batch_uuid].include?('-')
  end

  test 'batch_touch' do
    # Create a new batch record
    p = Pipeline.new(200, @initial_payload)
                .then(&batch_set)
    assert_not_nil p[:payload][:batch_uuid]
    assert p[:payload][:batch_uuid].include?('-')

    # Show that the created_at * updated_at columns are equal.
    batch = Batch.where(uuid: p[:payload][:batch_uuid]).first
    assert_equal batch.created_at, batch.updated_at

    # Sleep for a bit
    sleep(2)

    # Touch the batch record
    _p = Pipeline.new(200, @initial_payload.merge(batch_uuid: batch.uuid))
                 .then(&batch_touch)

    # Show that the created_at & updated_at columns are now different
    batch.reload
    assert_not_equal batch.created_at, batch.updated_at
  end
end
