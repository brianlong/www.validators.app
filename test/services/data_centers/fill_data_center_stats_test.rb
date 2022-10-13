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
  end
end
