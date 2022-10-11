# frozen_string_literal: true

require "test_helper"

# StakeStatsLogicTest
class StakeStatsLogicTest < ActiveSupport::TestCase
  include StakeStatsLogic

  test "#update_total_active_stake" do
    network = "mainnet"
    batch = create(:batch, :mainnet)
    batch_uuid = batch.uuid

    payload = {
      network: network,
      batch_uuid: batch_uuid
    }

    p = Pipeline.new(200, payload)
                .then(&update_total_active_stake)

    assert_equal network, report.network
    assert_equal batch_uuid, report.batch_uuid

    binding.pry
  end
end
