# frozen_string_literal: true

require "test_helper"

class DataCenterDistanceStatsTest < ActiveSupport::TestCase
  setup do
    @network = "testnet"
  end

  test "#average_root_distance_for and #average_vote_distance_for return the stored averages for a single data center" do
    dc = create(:data_center, :berlin)
    create(
      :data_center_stat,
      data_center: dc,
      network: @network,
      active_validators_count: 5,
      root_distance: { "average" => 10.0 },
      vote_distance: { "average" => 20.0 }
    )

    stats = DataCenterDistanceStats.new(@network)

    assert_equal 10.0, stats.average_root_distance_for(dc.data_center_key)
    assert_equal 20.0, stats.average_vote_distance_for(dc.data_center_key)
  end

  test "#average_root_distance_for returns nil when there is no computed distance stat" do
    dc = create(:data_center, :berlin)
    create(:data_center_stat, data_center: dc, network: @network)

    stats = DataCenterDistanceStats.new(@network)

    assert_nil stats.average_root_distance_for(dc.data_center_key)
    assert_nil stats.average_vote_distance_for(dc.data_center_key)
  end

  test "#average_root_distance_for returns nil for an unknown data center key" do
    stats = DataCenterDistanceStats.new(@network)

    assert_nil stats.average_root_distance_for("unknown-key")
  end

  test "#average_root_distance_for weights the average across multiple data centers by validators count" do
    dc1 = create(:data_center, :berlin)
    dc2 = create(:data_center, :frankfurt)
    create(
      :data_center_stat,
      data_center: dc1,
      network: @network,
      active_validators_count: 1,
      root_distance: { "average" => 10.0 },
      vote_distance: { "average" => 10.0 }
    )
    create(
      :data_center_stat,
      data_center: dc2,
      network: @network,
      active_validators_count: 3,
      root_distance: { "average" => 30.0 },
      vote_distance: { "average" => 30.0 }
    )

    stats = DataCenterDistanceStats.new(@network)

    # (10 * 1 + 30 * 3) / 4 = 25.0
    assert_equal 25.0, stats.average_root_distance_for([dc1.data_center_key, dc2.data_center_key])
    assert_equal 25.0, stats.average_vote_distance_for([dc1.data_center_key, dc2.data_center_key])
  end

  test "#average_root_distance_for ignores data centers from other networks" do
    dc = create(:data_center, :berlin)
    create(
      :data_center_stat,
      data_center: dc,
      network: "mainnet",
      root_distance: { "average" => 10.0 },
      vote_distance: { "average" => 10.0 }
    )

    stats = DataCenterDistanceStats.new(@network)

    assert_nil stats.average_root_distance_for(dc.data_center_key)
  end
end
