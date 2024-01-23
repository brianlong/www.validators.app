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
    assert_equal 0, array_average(['A','B','C'])
    assert_equal 1, array_average([1])
    assert_equal 2, array_average([1, nil, 3])
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

  test "validator_history_update with stubbed validators" do
    ValidatorHistory.delete_all
    assert_equal 0, ValidatorHistory.count

    json_data = {
      "validators": [
        {
          "identityPubkey": "4wjZmBoiwQ2s3fEL1og4gUcgWNtJoEkXNdG1yMW44nzr"
        },
        {
          "identityPubkey": "6X8sHQkmxRVh7oR94VjsfffmQYPoGZ62Fp8gt4QivszH"
        }
      ]
    }.to_json

    v = create(:validator, account: "4wjZmBoiwQ2s3fEL1og4gUcgWNtJoEkXNdG1yMW44nzr")

    SolanaCliService.stub(:request, json_data, ["validators", @testnet_url]) do
      VCR.use_cassette("validator_history_update") do
        p = Pipeline.new(200, @testnet_initial_payload)
                    .then(&batch_set)
                    .then(&validator_history_update)

        validator_histories = ValidatorHistory.where(batch_uuid: p.payload[:batch_uuid])

        assert_equal 200, p.code
        assert validator_histories.size == 1
        assert validator_histories.first.validator, v
      end
    end
  end

  test "validator_history_update returns no validator from blacklist" do
    ValidatorHistory.delete_all
    assert_equal 0, ValidatorHistory.count

    json_data = File.read("#{Rails.root}/test/json/validators_from_blacklist.json")
    SolanaCliService.stub(:request, json_data, ["validators", @testnet_url]) do
      VCR.use_cassette("validator_history_update_blacklist") do
        p = Pipeline.new(200, @testnet_initial_payload)
                    .then(&batch_set)
                    .then(&validator_history_update)

        validator_histories = ValidatorHistory.where(batch_uuid: p.payload[:batch_uuid])

        assert_equal 200, p.code
        assert_empty validator_histories
      end
    end
  end

  test "validator_history_update with validator_histories without validator relations" do
    ValidatorHistory.delete_all
    assert_equal 0, ValidatorHistory.count

    json_data = File.read("#{Rails.root}/test/json/validators.json")
    SolanaCliService.stub(:request, json_data, ["validators", @testnet_url]) do
      VCR.use_cassette("validator_history_update") do
        p = Pipeline.new(200, @testnet_initial_payload)
                    .then(&batch_set)
                    .then(&validator_history_update)

        validator_histories = ValidatorHistory.where(batch_uuid: p.payload[:batch_uuid])

        assert_equal 200, p.code
        assert validator_histories.count.zero?
      end
    end
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

  test '#validators_info_save updates data for existing validators' do
    #  To skip validators_info_get
    payload = @mainnet_initial_payload.merge(
      validators_info: @validators_info
    )

    create(:validator, :mainnet, account: '61QB1Evn9E3noQtpJm4auFYyHSXS5FPgqKtPgwJJfEQk')

    VCR.use_cassette('validators_info_save') do
      p = Pipeline.new(200, payload)
                  .then(&program_accounts)
                  .then(&validators_info_save)
      assert_equal 2, Validator.count

      validator = Validator.find_by(account: '61QB1Evn9E3noQtpJm4auFYyHSXS5FPgqKtPgwJJfEQk')
      assert_equal 'Meyerbro', validator.name
      assert_equal 'meyerbro', validator.keybase_id
      assert_equal 'Since epoch 196 (Jun 2021) - AMD EPYC 10Gbps NYC DC', validator.details
      assert_equal 'https://meyerbro.s3.eu-west-2.amazonaws.com/meyerbro-validator-logo.jpg', validator.avatar_url
      assert_equal 'https://tinyurl.com/meyerbro', validator.www_url
    end
  end

  test '#validators_info_save does not save incorrect attributes' do
    #  To skip validators_info_get
    payload = @mainnet_initial_payload.merge(
      validators_info: @validators_info
    )

    create(:validator, :mainnet, account: '7MTjmteQHhthwwTZhUzsc2dP4NBvGNRqj8jzdqNxHFGE', avatar_url: nil)

    VCR.use_cassette('validators_info_save') do
      p = Pipeline.new(200, payload)
                  .then(&program_accounts)
                  .then(&validators_info_save)
      assert_equal 2, Validator.count

      validator = Validator.find_by(account: '7MTjmteQHhthwwTZhUzsc2dP4NBvGNRqj8jzdqNxHFGE')
      assert_equal 'web34ever', validator.name
      assert_equal 'web34ever', validator.keybase_id
      assert_equal 'Crypto is going mainstream. We help you go upstream', validator.details
      assert_nil validator.avatar_url
      assert_nil validator.www_url
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
end
