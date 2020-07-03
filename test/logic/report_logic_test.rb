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
      config_url: Rails.application.credentials.solana[:testnet_url],
      network: 'testnet'
    }
  end

  test 'report_tower_height' do
    # Empty the ValidatorHistory table
    ValidatorHistory.delete_all
    assert_equal 0, ValidatorHistory.count

    # NOTE: This VCR cassette is not capturing the network events because Ruby
    # is not making the network calls. In the future, we might change the CLI
    # call to RPC and then the VCR cassette will work.
    VCR.use_cassette('report_tower_height') do
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
