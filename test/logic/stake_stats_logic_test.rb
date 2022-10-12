# frozen_string_literal: true

require "test_helper"

# StakeStatsLogicTest
class StakeStatsLogicTest < ActiveSupport::TestCase
  include StakeStatsLogic

  test "#update_total_active_stake" do
    network = "mainnet"
    batch = create(:batch, :mainnet)
    batch_uuid = batch.uuid

    create(:validator_history, batch_uuid: batch_uuid, network: network)

    payload = {
      network: network,
      batch_uuid: batch_uuid
    }

    p = Pipeline.new(200, payload)
                .then(&update_total_active_stake)

    cluster_stat = ClusterStat.where(network: network).last
    total_active_stake = 100

    assert_equal network, cluster_stat.network
    assert_equal total_active_stake, cluster_stat.total_active_stake
  end
end
