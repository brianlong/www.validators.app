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

  test 'array_average' do
    assert_equal 2, array_average([1,2,3])
    assert_nil array_average('TEST')
    assert_nil array_average(nil)
    assert_nil array_average([])
    assert_equal 'ABC', ['A','B','C'].sum
    assert_equal 0, ['A','B','C'].sum.to_i
    assert_equal 0, array_average(['A','B','C'])
    assert_equal 1, array_average([1])
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

  test 'epoch_get with fail_over' do
    VCR.use_cassette('epoch_get_with_fail_over') do
      fail_over_payload = {
        # This assumes that there is no RPC server running on the localhost!
        config_urls: [
          'http://127.0.0.1:8899',
          'http://testnet.solana.com:8899'
        ],
        network: 'testnet'
      }

      p = Pipeline.new(200, fail_over_payload)
                  .then(&batch_set)
                  .then(&epoch_get)

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

  test 'epoch_get with no response' do
    VCR.use_cassette('epoch_get_no_response') do
      no_response_payload = {
        # This assumes that there is no RPC server running on the localhost!
        config_urls: ['http://127.0.0.1:8899'],
        network: 'testnet'
      }

      p = Pipeline.new(200, no_response_payload)
                  .then(&batch_set)
                  .then(&epoch_get)

      assert_equal 500, p.code
    end
  end

  test 'validators_cli' do
    # Empty the ValidatorHistory table
    ValidatorHistory.delete_all
    assert_equal 0, ValidatorHistory.count

    # We need ot stub both the cli call in plus the POST http://165.227.100.142:8899/ call
    json_data = File.read("#{Rails.root}/test/json/validators.json")
    SolanaCliService.stub(:request, json_data, ['validators', 'http://165.227.100.142:8899']) do
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

  # This test assumes that there is no validator RPC running locally.
  # 159.89.252.85 is my testnet server.
  test 'cli_request with fail over' do
    json_data = File.read("#{Rails.root}/test/json/validators.json")
    SolanaCliService.stub(:request, json_data, ['validators', 'http://testnet.solana.com:8899']) do
      rpc_urls = ['http://127.0.0.1:8899', 'http://testnet.solana.com:8899']
      cli_response = cli_request('validators', rpc_urls)
      assert_equal 6, cli_response.count
    end
  end

  # This test assumes that there is no validator RPC running locally.
  test 'cli_request should get first attempt with no fail over' do
    json_data = File.read("#{Rails.root}/test/json/validators.json")
    SolanaCliService.stub(:request, json_data, ['validators', 'http://testnet.solana.com:8899']) do
      rpc_urls = ['https://testnet.solana.com:8899', 'http://127.0.0.1:8899']
      cli_response = cli_request('validators', rpc_urls)
      assert_equal 6, cli_response.count
    end
  end

  # This test assumes that there is no validator RPC running locally.
  test 'cli_request with no response' do
    VCR.use_cassette('validators_cli_no_response') do
      rpc_urls = ['http://127.0.0.1:8899']

      assert_equal [], cli_request('validators', rpc_urls)
    end
  end

  # I use this test in development mode only.
  # test 'cli_block_production_mainnet' do
  #   VCR.use_cassette('cli_block_production_mainnet') do
  #     rpc_urls = ['https://api.mainnet-beta.solana.com']
  #
  #     assert_equal [], cli_request('block-production', rpc_urls)
  #   end
  # end
end
