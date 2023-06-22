# frozen_string_literal: true

require 'test_helper'
require 'sidekiq/testing'

# ReportLogicTest
class ReportLogicTest < ActiveSupport::TestCase
  include ReportLogic
  include SolanaLogic

  def setup
    # Create our initial payload with the input values
    @initial_payload = {
      # config_urls: Rails.application.credentials.solana[:testnet_urls],
      config_urls: [
        'https://api.testnet.solana.com',
        'http://165.227.100.142:8899',
        'http://127.0.0.1:8899'
      ],
      network: 'testnet'
    }
  end

  test "report_software_versions creates correct report and ignores empty and 'unknown' software_versions" do
    network = 'mainnet'
    batch = create(:batch, :mainnet)

    batch_uuid = batch.uuid

    software_versions = ['1.6.8', '1.7.1', '1.7.2']
    validator_lists = []

    software_versions.each do |sw|
      list = create_list(:validator, 5, network: network)
      list.each do |val|
        create(
          :validator_score_v1, 
          validator: val, 
          software_version: sw,
          network: network
        )
      end

      validator_lists << list
    end

    # Setup score with empty software version, should be ignored in the report
    val = create(:validator)
    create(
      :validator_score_v1, 
      validator: val, 
      software_version: '',
      network: network
    )

    # Setup score with 'unknown' software version, should be ignored in the report
    val_unknown = create(:validator)
    create(
      :validator_score_v1, 
      validator: val, 
      software_version: 'unknown',
      network: network
    )

    # Setup score with malformed software version, should be ignored in the report
    val_malformed = create(:validator)
    create(
      :validator_score_v1, 
      validator: val, 
      software_version: '1.3.9 e45f1df5',
      network: network
    )

    # Setup score with blank active_stake_sum should be ignored in the report
    validator = create(:validator, network: network)
    create(
      :validator_score_v1,
      software_version: "1.4.7",
      validator: validator,
      active_stake: nil
    )

    validator_lists.each do |list|
      list.each do |val|
        va = create(:vote_account, validator: val)
        create(:vote_account_history, vote_account: va, batch_uuid: batch_uuid, network: network)
      end
    end

    va_unknown = create(:vote_account, validator: val_unknown)
    create(:vote_account_history, vote_account: va_unknown, batch_uuid: batch_uuid, network: network)
  
    va_malformed = create(:vote_account, validator: val_malformed)
    create(:vote_account_history, vote_account: va_malformed, batch_uuid: batch_uuid, network: network)

    payload = {
      network: network,
      batch_uuid: batch_uuid
    }

    _p = Pipeline.new(200, payload)
                .then(&report_software_versions)

    report = Report.find_by(name: 'report_software_versions', batch_uuid: batch_uuid)     
    
    expected_result = {"count"=>5, "stake_percent"=>33.33}

    assert_equal network, report.network
    assert_equal batch_uuid, report.batch_uuid
    assert_equal 3, report.payload.size # empty and unknown software_versions are ignored

    software_versions.each do |sw|
      assert_equal report.payload.find { |v| v[sw] }[sw], expected_result
    end
  end
end
