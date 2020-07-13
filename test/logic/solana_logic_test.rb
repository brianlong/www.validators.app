# frozen_string_literal: true

require 'test_helper'

# SolanaLogicTest
class SolanaLogicTest < ActiveSupport::TestCase
  include SolanaLogic

  def setup
    # Create our initial payload with the input values
    @initial_payload = {
      # config_urls: Rails.application.credentials.solana[:testnet_urls],
      config_urls: [
        'http://165.227.100.142:8899',
        'http://testnet.solana.com:8899',
        'http://127.0.0.1:8899'
      ],
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

  test 'epoch_get' do
    VCR.use_cassette('epoch_get') do
      # Show that the pipeline runs & the expected values are not empty.
      p = Pipeline.new(200, @initial_payload)
                  .then(&batch_set)
                  .then(&epoch_get)
      puts p.inspect

      assert_equal 200, p.code
      assert_not_nil p.payload[:epoch]
      assert_not_nil p.payload[:batch_uuid]

      # Find the EpochHistory record and show that the values match
      epoch = EpochHistory.where(batch_uuid: p.payload[:batch_uuid]).first
      assert_equal p.payload[:epoch], epoch.epoch
      assert_equal p.payload[:batch_uuid], epoch.batch_uuid
      assert_not_nil epoch.current_slot
      assert_not_nil epoch.slot_index
      assert_not_nil epoch.slots_in_epoch
    end
  end

  test 'validators_cli' do
    # Empty the ValidatorHistory table
    ValidatorHistory.delete_all
    assert_equal 0, ValidatorHistory.count

    # NOTE: This VCR cassette is not captuing the network events because Ruby is
    # not making the network calls. In the future, we might change the CLI call
    # to RPC and then the VCR cassette will work.
    VCR.use_cassette('validators_cli') do
      # Show that the pipeline runs & the expected values are not empty.
      p = Pipeline.new(200, @initial_payload)
                  .then(&batch_set)
                  .then(&epoch_get)
                  .then(&validators_cli)

      assert_equal 200, p.code
      assert_not_nil p.payload[:epoch]
      assert_not_nil p.payload[:batch_uuid]

      # Find the EpochHistory record and show that the values match
      validators = ValidatorHistory.where(
        batch_uuid: p.payload[:batch_uuid]
      ).all
      assert validators.count.positive?
    end
  end
end
