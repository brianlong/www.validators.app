# frozen_string_literal: true

class CreateClusterStatsServiceTest < ActiveSupport::TestCase
  def setup
    @network = "mainnet"
    @software_version =  "1.1.1"
    @batch = create(:batch, network: @network, software_version: @software_version)

    @validator_histories = [
      create(:validator_history, batch_uuid: @batch_uuid, active_stake: 10),
      create(:validator_history, batch_uuid: @batch_uuid, active_stake: 20),
      create(:validator_history, batch_uuid: @batch_uuid, active_stake: 31),
    ]

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

    create(:gossip_node, network: @network, staked: true)
    
    CreateClusterStatsService.new(network: @network, batch_uuid: @batch.uuid).call
    stat = ClusterStat.where(network: @network).last

    assert_equal @software_version, stat.software_version
    assert_equal 5, stat.validator_count
    assert_equal 5, stat.nodes_count
  end
end
