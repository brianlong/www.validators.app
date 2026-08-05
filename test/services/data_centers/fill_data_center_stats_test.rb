# frozen_string_literal: true

require "test_helper"
module DataCenters
  class FillDataCenterStatsTest < ActiveSupport::TestCase
    setup do
      @network = "mainnet"
      @data_center = create(:data_center, :berlin)
      host = create(:data_center_host, data_center: @data_center)
      @validator = create(:validator, network: @network, is_active: false)
      @node1 = create(:gossip_node, :inactive, network: @network)
      @node2 = create(:gossip_node, :inactive, network: @network)
      create(:validator_ip, :active, data_center_host: host, address: @node1.ip)
      create(:validator_ip, :active, data_center_host: host, address: @node2.ip, validator: @validator)
    end

    test "#call creates new data_center_stats if required" do
      refute DataCenterStat.exists?

      DataCenters::FillDataCenterStats.new(network: @network).call

      assert DataCenterStat.exists?
      assert @data_center.data_center_stats.exists?
    end

    test "#call does not create the same data_center_stats twice" do
      refute DataCenterStat.exists?

      assert_changes "DataCenterStat.count" do
        DataCenters::FillDataCenterStats.new(network: @network).call
      end

      assert_no_difference "DataCenterStat.count" do
        DataCenters::FillDataCenterStats.new(network: @network).call
      end
    end

    test "#call sets up validator_count and gossip_node_count correctly" do
      DataCenters::FillDataCenterStats.new(network: @network).call

      assert_equal 1, @data_center.data_center_stats.by_network(@network).validators_count
      assert_equal 2, @data_center.data_center_stats.by_network(@network).gossip_nodes_count
    end

    test "#call sets up active_validators_count and active_gossip_nodes_count correctly" do
      DataCenters::FillDataCenterStats.new(network: @network).call

      assert_equal 0, @data_center.data_center_stats.by_network(@network).active_validators_count
      assert_equal 0, @data_center.data_center_stats.by_network(@network).active_gossip_nodes_count

      @validator.update(is_active: true)
      @node1.update(is_active: true)
      DataCenters::FillDataCenterStats.new(network: @network).call

      assert_equal 1, @data_center.data_center_stats.by_network(@network).active_validators_count
      assert_equal 1, @data_center.data_center_stats.by_network(@network).validators_count
      assert_equal 1, @data_center.data_center_stats.by_network(@network).active_gossip_nodes_count
      assert_equal 2, @data_center.data_center_stats.by_network(@network).gossip_nodes_count
    end

    test "#call leaves root_distance and vote_distance blank when there is no scored batch" do
      DataCenters::FillDataCenterStats.new(network: @network).call

      stats = @data_center.data_center_stats.by_network(@network)
      assert_nil stats.root_distance
      assert_nil stats.vote_distance
    end

    test "#call sets root_distance and vote_distance stats for the latest scored batch" do
      batch = create(:batch, network: @network)
      create(
        :validator_history,
        network: @network,
        batch_uuid: batch.uuid,
        validator: @validator,
        root_distance: 10,
        vote_distance: 20
      )

      DataCenters::FillDataCenterStats.new(network: @network).call

      stats = @data_center.data_center_stats.by_network(@network)
      assert_equal({ "min" => 10, "max" => 10, "median" => 10, "average" => 10.0 }, stats.root_distance)
      assert_equal({ "min" => 20, "max" => 20, "median" => 20, "average" => 20.0 }, stats.vote_distance)
    end

    test "#call averages root_distance and vote_distance across validators sharing a data center" do
      host = @data_center.data_center_hosts.first
      other_validator = create(:validator, network: @network, is_active: false)
      create(:validator_ip, :active, data_center_host: host, validator: other_validator)

      batch = create(:batch, network: @network)
      create(:validator_history, network: @network, batch_uuid: batch.uuid, validator: @validator, root_distance: 10, vote_distance: 20)
      create(:validator_history, network: @network, batch_uuid: batch.uuid, validator: other_validator, root_distance: 30, vote_distance: 40)

      DataCenters::FillDataCenterStats.new(network: @network).call

      stats = @data_center.data_center_stats.by_network(@network)
      assert_equal 20.0, stats.root_distance["average"]
      assert_equal 30.0, stats.vote_distance["average"]
    end

    test "#call uses the explicitly given batch_uuid instead of the latest scored batch" do
      create(:batch, network: @network)
      create(
        :validator_history,
        network: @network,
        batch_uuid: Batch.last_scored(@network).uuid,
        validator: @validator,
        root_distance: 999,
        vote_distance: 999
      )

      other_batch = create(:batch, network: @network)
      create(
        :validator_history,
        network: @network,
        batch_uuid: other_batch.uuid,
        validator: @validator,
        root_distance: 5,
        vote_distance: 6
      )

      DataCenters::FillDataCenterStats.new(network: @network, batch_uuid: other_batch.uuid).call

      stats = @data_center.data_center_stats.by_network(@network)
      assert_equal 5, stats.root_distance["average"]
      assert_equal 6, stats.vote_distance["average"]
    end
  end
end
