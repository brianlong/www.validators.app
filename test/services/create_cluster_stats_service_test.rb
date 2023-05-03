# frozen_string_literal: true

require "test_helper"

class CreateClusterStatsServiceTest < ActiveSupport::TestCase
  def setup
    @network = "mainnet"
    @software_version =  "1.1.1"
    @batch = create(:batch, network: @network, software_version: @software_version)
  end

  test "#call creates new ClusterStat with correct data if there's no cluster stats for given network" do
    CreateClusterStatsService.new(network: @network, batch_uuid: @batch.uuid).call

    assert ClusterStat.exists?
    assert ValidatorHistory.all.sum(&:active_stake), ClusterStat.last.total_active_stake
  end

  test "#call updates ClusterStat for network if it exists" do
    cluster_stat = create(:cluster_stat, network: @network, total_active_stake: 0)
    CreateClusterStatsService.new(network: @network, batch_uuid: @batch.uuid).call

    assert_equal 1, ClusterStat.where(network: @network).count
    assert ValidatorHistory.all.sum(&:active_stake), cluster_stat.total_active_stake
  end

  test "#call updates ClusterStat with correct values" do
    5.times do |n|
      create(:gossip_node, network: @network)
      create(:validator, network: @network)
    end

    create(
      :epoch_wall_clock,
      created_at: 6.days.ago,
      network: @network,
      epoch: 1,
      starting_slot: 1,
      ending_slot: 2,
      total_rewards: 100,
      total_active_stake: 1000
    )

    create(
      :epoch_wall_clock,
      created_at: 3.days.ago,
      network: @network,
      epoch: 2,
      starting_slot: 3,
      ending_slot: 4,
      total_rewards: 100,
      total_active_stake: 1000
    )

    create(
      :epoch_wall_clock,
      network: @network,
      epoch: 3,
      starting_slot: 5,
      ending_slot: 6,
      total_rewards: 100,
      total_active_stake: 1000
    )
    
    CreateClusterStatsService.new(network: @network, batch_uuid: @batch.uuid).call
    stat = ClusterStat.where(network: @network).last

    assert_equal @software_version, stat.software_version
    assert_equal 5, stat.validator_count
    assert_equal 5, stat.nodes_count
    assert_equal 3043.69, stat.roi
  end

  test "#call updates ClusterStat with correct total_active_stake" do
    mock = Minitest::Mock.new
    mock.expect :total_active_stake, 123
    mock.expect :total_active_stake, 123
    mock.expect :total_active_stake, 123

    Stats::ValidatorHistory.stub :new, mock do
      CreateClusterStatsService.new(network: @network, batch_uuid: @batch.uuid).call
      stat = ClusterStat.where(network: @network).last

      assert_equal 123, stat.total_active_stake
    end
  end

  test "#call updates ClusterStat with correct root_distance and vote_distance" do
    mock = Minitest::Mock.new
    mock.expect :root_distance_stats, { max: 456 }
    mock.expect :root_distance_stats, { max: 456 }
    mock.expect :vote_distance_stats, { max: 789 }
    mock.expect :vote_distance_stats, { max: 789 }
    mock.expect :vote_distance_stats, { max: 789 }


    Stats::ValidatorScore.stub :new, mock do
      CreateClusterStatsService.new(network: @network, batch_uuid: @batch.uuid).call
      stat = ClusterStat.where(network: @network).last

      assert_equal 456, stat.root_distance["max"]
      assert_equal 789, stat.vote_distance["max"]
    end
  end

  test "#call updates ClusterStat with correct skipped_slots" do
    mock = Minitest::Mock.new
    mock.expect :skipped_slot_stats, { max: 111 }
    mock.expect :skipped_slot_stats, { max: 111 }

    Stats::ValidatorBlockHistory.stub :new, mock do
      CreateClusterStatsService.new(network: @network, batch_uuid: @batch.uuid).call
      stat = ClusterStat.where(network: @network).last

      assert_equal 111, stat.skipped_slots["max"]
    end
  end

  test "#call updates ClusterStat with correct skipped_votes" do
    mock = Minitest::Mock.new
    mock.expect :skipped_votes_stats, { max: 222 }
    mock.expect :skipped_votes_stats, { max: 222 }

    Stats::VoteAccountHistory.stub :new, mock do
      CreateClusterStatsService.new(network: @network, batch_uuid: @batch.uuid).call
      stat = ClusterStat.where(network: @network).last

      assert_equal 222, stat.skipped_votes["max"]
    end
  end
end
