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
        'http://165.227.100.142:8899',
        'http://testnet.solana.com:8899',
        'http://127.0.0.1:8899'
      ],
      network: 'testnet'
    }
  end

  test 'report_tower_height' do
    # Empty the ValidatorHistory table
    ValidatorHistory.delete_all
    assert_equal 0, ValidatorHistory.count

    VCR.use_cassette('report_tower_height') do
      json_data = File.read("#{Rails.root}/test/json/validators.json")
      SolanaCliService.stub(:request, json_data, ['validators', 'http://165.227.100.142:8899/']) do
        # Show that the pipeline runs & the expected values are not empty.
        p = Pipeline.new(200, @initial_payload)
                    .then(&batch_set)
                    .then(&epoch_get)
                    .then(&validators_cli)

        assert_equal 200, p.code
        assert_not_nil p.payload[:epoch]
        assert_not_nil p.payload[:batch_uuid]

        validators = ValidatorHistory.where(
          batch_uuid: p.payload[:batch_uuid]
        ).all
        assert validators.count.positive?

        Sidekiq::Testing.inline! do
          ReportTowerHeightWorker.perform_async(
            epoch: p.payload[:epoch],
            batch_uuid: p.payload[:batch_uuid],
            network: p.payload[:network]
          )
          # sleep(5) # wait for the report
          report = Report.where(
            network: 'testnet',
            batch_uuid: p.payload[:batch_uuid],
            name: 'report_tower_height'
          ).last

          # puts report.inspect

          assert_equal p.payload[:network], report.network
          assert_equal p.payload[:batch_uuid], report.batch_uuid
          assert report.payload.count.positive?
        end
      end
    end
  end

  test 'report_software_versions' do
    Sidekiq::Testing.inline! do
      ReportSoftwareVersionWorker.perform_async(
        batch_uuid: '1-2-3',
        network: 'testnet'
      )
      # sleep(5) # wait for the report
      report = Report.where(
        network: 'testnet',
        batch_uuid: '1-2-3',
        name: 'report_software_versions'
      ).last

      # puts report.inspect

      assert_equal 'testnet', report.network
      assert_equal '1-2-3', report.batch_uuid
      assert report.payload.count.positive?
    end

    # report_payload = {
    #   network: 'testnet',
    #   batch_uuid: '1-2-3'
    # }
    # p = Pipeline.new(200, report_payload)
    #             .then(&report_software_versions)
    # puts p.inspect
    # assert_equal 200, p.code
    #
    # report = Report.where(
    #   network: 'testnet',
    #   batch_uuid: report_payload[:batch_uuid],
    #   name: 'report_software_versions'
    # ).last
    #
    # assert_equal p.payload[:network], report.network
    # assert_equal p.payload[:batch_uuid], report.batch_uuid
    # assert report.payload.count.positive?
  end
end
