# frozen_string_literal: true

require 'test_helper'

# SolanaLogicTest
class SolanaLogicTest < ActiveSupport::TestCase
  include SolanaLogic

  def setup
    @testnet_url = 'https://api.testnet.solana.com'
    @mainnet_url = 'https://api.mainnet-beta.solana.com'

    @local_url = 'http://127.0.0.1:8899'
    # Create our initial payload with the input values
    @testnet_initial_payload = {
      # config_urls: Rails.application.credentials.solana[:testnet_urls],
      config_urls: [
        @testnet_url,
        @local_url
      ],
      network: 'testnet'
    }

    @mainnet_initial_payload = {
      # config_urls: Rails.application.credentials.solana[:testnet_urls],
      config_urls: [
        @mainnet_url
      ],
      network: 'mainnet'
    }

    validators_info
  end

  def validators_info
    validators_info = file_fixture('validators_info.json')
    @validators_info ||= JSON.parse(validators_info.read)
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
    p = Pipeline.new(200, @testnet_initial_payload)
                .then(&batch_set)
    assert_not_nil p[:payload][:batch_uuid]
    assert p[:payload][:batch_uuid].include?('-')
  end

  test 'batch_touch' do
    # Create a new batch record
    p = Pipeline.new(200, @testnet_initial_payload)
                .then(&batch_set)

    batch = Batch.where(uuid: p[:payload][:batch_uuid]).first

    list = create_list(
      :validator_block_history, 3, 
      batch_uuid: p[:payload][:batch_uuid],
      network: p[:payload][:network]
    )
    list.each do |el|
      # to skip callback
      el.update_column(:skipped_slot_percent_moving_average, 5)
    end

    assert_not_nil p[:payload][:batch_uuid]
    assert p[:payload][:batch_uuid].include?('-')

    # Show that the created_at * updated_at columns are equal.
    assert_equal batch.created_at, batch.updated_at

    # Sleep for a bit
    sleep(2)

    # Touch the batch record
    _p = Pipeline.new(200, @testnet_initial_payload .merge(batch_uuid: batch.uuid))
                 .then(&batch_touch)

    # Show that the created_at & updated_at columns are now different
    batch.reload
    assert_not_equal batch.created_at, batch.updated_at
    assert_equal batch.skipped_slot_all_average, 5
  end

  test 'epoch_get' do
    VCR.use_cassette('epoch_get') do
      # Show that the pipeline runs & the expected values are not empty.
      p = Pipeline.new(200, @testnet_initial_payload)
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
    # We need to stub both the cli call (using minitest stub)
    # plus the POST https://api.testnet.solana.com/ call (using VCR)
    json_data = File.read("#{Rails.root}/test/json/validators.json")
    SolanaCliService.stub(:request, json_data, ['validators', @testnet_url]) do
      VCR.use_cassette('epoch_get_with_fail_over') do
        fail_over_payload = {
          # This assumes that there is no RPC server running on the localhost!
          config_urls: [
            @local_url,
            @testnet_url
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
  end

  test 'epoch_get with no response' do
    VCR.use_cassette('epoch_get_no_response') do
      no_response_payload = {
        # This assumes that there is no RPC server running on the localhost!
        config_urls: [@local_url],
        network: 'testnet'
      }

      p = Pipeline.new(200, no_response_payload)
                  .then(&batch_set)
                  .then(&epoch_get)

      assert_equal 500, p.code
    end
  end

  test "validators_cli with stubbed validators" do
    ValidatorHistory.delete_all
    assert_equal 0, ValidatorHistory.count

    json_data = File.read("#{Rails.root}/test/json/validators.json")
    SolanaCliService.stub(:request, json_data, ['validators', @testnet_url]) do
      VCR.use_cassette('validators_cli') do
        Validator.stub :find_by, true do
          p = Pipeline.new(200, @testnet_initial_payload)
                      .then(&batch_set)
                      .then(&validators_cli)
                      
          validator_histories = ValidatorHistory.where(batch_uuid: p.payload[:batch_uuid])
                      
          assert_equal 200, p.code
          assert validator_histories.count.positive?
        end
      end
    end
  end

  test "validators_cli returns no validator from blacklist" do
    ValidatorHistory.delete_all
    assert_equal 0, ValidatorHistory.count

    json_data = File.read("#{Rails.root}/test/json/validators_from_blacklist.json")
    SolanaCliService.stub(:request, json_data, ["validators", @testnet_url]) do
      VCR.use_cassette("validators_cli_blacklist") do
        p = Pipeline.new(200, @testnet_initial_payload)
                    .then(&batch_set)
                    .then(&validators_cli)
        
        validator_histories = ValidatorHistory.where(batch_uuid: p.payload[:batch_uuid])

        assert_equal 200, p.code
        assert_empty validator_histories
      end
    end
  end

  test "validators_cli with validator_histories without validator relations" do
    ValidatorHistory.delete_all
    assert_equal 0, ValidatorHistory.count

    json_data = File.read("#{Rails.root}/test/json/validators.json")
    SolanaCliService.stub(:request, json_data, ["validators", @testnet_url]) do
      VCR.use_cassette("validators_cli") do
        p = Pipeline.new(200, @testnet_initial_payload)
                    .then(&batch_set)
                    .then(&validators_cli)

        validator_histories = ValidatorHistory.where(batch_uuid: p.payload[:batch_uuid])
                    
        assert_equal 200, p.code
        assert validator_histories.count.zero?
      end
    end
  end

  # This test assumes that there is no validator RPC running locally.
  # 159.89.252.85 is my testnet server.
  test 'cli_request with fail over' do
    json_data = File.read("#{Rails.root}/test/json/validators.json")
    SolanaCliService.stub(:request, json_data, ['validators', @testnet_url]) do
      rpc_urls = [@local_url, @testnet_url]
      cli_response = cli_request('validators', rpc_urls)

      assert_equal 5, cli_response.count
    end
  end

  # This test assumes that there is no validator RPC running locally.
  test 'cli_request should get first attempt with no fail over' do
    json_data = File.read("#{Rails.root}/test/json/validators.json")
    SolanaCliService.stub(:request, json_data, ['validators', @testnet_url]) do
      rpc_urls = [@testnet_url, @local_url]
      cli_response = cli_request('validators', rpc_urls)

      assert_equal 5, cli_response.count
    end
  end

  # This test assumes that there is no validator RPC running locally.
  test 'cli_request with no response' do
    rpc_urls = [@local_url]
    assert_equal [], cli_request('validators', rpc_urls)
  end

  test 'check_epoch removes epoch history when check fails' do
    VCR.use_cassette('check_epoch') do
      # Show that the pipeline runs & the expected values are not empty.
      p = Pipeline.new(200, @testnet_initial_payload)

      # First, save the epoch
      assert_difference 'EpochHistory.count' do
        p = p.then(&batch_set)
                      .then(&epoch_get)
      end

      # Then, if epoch is different - removes epoch
      assert_difference 'EpochHistory.count', -1 do
        p.then(&check_epoch)
      end
    end
  end

  test 'program_accounts' do
    config_program_pubkey = 'Config1111111111111111111111111111111111111'

    VCR.use_cassette('testnet_program_accounts') do
      # Show that the pipeline runs & the expected values are not empty.
      p = Pipeline.new(200, @testnet_initial_payload)
                  .then(&program_accounts)

      assert_equal 1386, p.payload[:program_accounts].size
    end

    VCR.use_cassette('mainnet_program_accounts') do
      # Show that the pipeline runs & the expected values are not empty.
      p = Pipeline.new(200, @mainnet_initial_payload)
                  .then(&program_accounts)

      assert_equal 870, p.payload[:program_accounts].size
    end
  end

  test 'validators_info_save' do
    #  To skip validators_info_get
    payload = @mainnet_initial_payload.merge(
      validators_info: @validators_info
    )

    VCR.use_cassette('validators_info_save') do
      p = Pipeline.new(200, payload)
                  .then(&program_accounts)
                  .then(&validators_info_save)
      assert_equal 898, Validator.count
    end
  end

  test 'find_invalid_configs' do
    #  To skip validators_info_get
    payload = @mainnet_initial_payload.merge(
      validators_info: @validators_info
    )

    VCR.use_cassette('find_invalid_configs') do
      p = Pipeline.new(200, payload)
                  .then(&program_accounts)
      
      assert_equal 899, p.payload[:validators_info].size
      assert_equal 904, p.payload[:program_accounts].size

      config_account = p.payload[:program_accounts][0]['account']['data']['parsed']['info']['keys'][1]
      config_account['signer'] = false

      p = p.then(&find_invalid_configs)

      # One vailidator has info set to empty hash due to having false signer.
      assert_equal config_account['pubkey'], p.payload[:false_signers].first[1]['pubkey']
      assert_equal [
          "4En2EzuCGjsXDAmWpecmQz2Z2sBrPZAfrDqP35qcTUhu", 
          "H4hqVttu3AXbUZeUGtV5hxQRg1VUDMXdMzz84P76PLhN", 
          "DPe3AebFaHfSRJjt1rcFWZWfSUsEa3MmLpBLZNheLUXx", 
          "3j1hSHKYgLVydvv35DmcELex7YfoKSV4E7biK765ECZb"
        ], 
        p.payload[:duplicated_configs].values.flatten
    end
  end

  test 'remove_invalid_configs' do
    #  To skip validators_info_get
    payload = @mainnet_initial_payload.merge(
      validators_info: @validators_info
    )

    VCR.use_cassette('remove_invalid_configs') do
      p = Pipeline.new(200, payload)
                  .then(&program_accounts)
                  
      assert_equal 899, p.payload[:validators_info].size
      assert_equal 904, p.payload[:program_accounts].size

      config_account = p.payload[:program_accounts][0]['account']['data']['parsed']['info']['keys'][1]
      config_account['signer'] = false

      p = p.then(&find_invalid_configs)
           .then(&remove_invalid_configs)

      # One validator has info set to empty hash due to having false signer.
      assert_equal 898, p.payload[:validators_info].size
    end
  end

  test 'solana_client_request returns data found in first cluster' do
    clusters = [
      @mainnet_url,
      @testnet_url
    ]

    method = :get_epoch_info

    VCR.use_cassette('solana_client_request') do
      result = solana_client_request(clusters, method)
      assert_equal result["epoch"], 202
    end
  end

  test 'solana_client_request returns data even if one of the clusters is incorrect' do
    clusters = [
      @local_url,
      @testnet_url
    ]

    method = :get_epoch_info

    VCR.use_cassette('solana_client_request incorrect cluster') do
      result = solana_client_request(clusters, method)
      assert_equal result["epoch"], 209
    end
  end

  test 'solana_client_request returns data with optional params' do
    clusters = [
      @mainnet_url
    ]

    method = :get_program_accounts
    config_program_pubkey = 'Config1111111111111111111111111111111111111'
    params = [config_program_pubkey, { encoding: 'jsonParsed' }]

    VCR.use_cassette('solana_client_request optional params') do
      result = solana_client_request(clusters, method, params: params)
      assert_equal 863, result.size
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
