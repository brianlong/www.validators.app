# frozen_string_literal: true

require "test_helper"

module ClusterStats
  class UpdateEpochDurationServiceTest < ActiveSupport::TestCase
    setup do
      @network = "testnet"

      create(:epoch_wall_clock, epoch: 301, created_at: 15.days.ago)
      create(:epoch_wall_clock, epoch: 302, created_at: 12.5.days.ago)
      create(:epoch_wall_clock, epoch: 303, created_at: 10.days.ago)
      create(:epoch_wall_clock, epoch: 304, created_at: 7.5.days.ago)
      create(:epoch_wall_clock, epoch: 305, created_at: 5.days.ago)
      create(:epoch_wall_clock, epoch: 306, created_at: 2.5.days.ago)
    end

    test "updates epoch duration" do
      cluster_stat = ClusterStat.last
      cluster_stat.update(epoch_duration: 0)

      ClusterStats::UpdateEpochDurationService.new(@network).call

      assert_equal 216000.0, cluster_stat.reload.epoch_duration
    end

    test "updates epoch duration if there are less of epoch_wall_clock records" do
      network = "mainnet"

      create(:epoch_wall_clock, epoch: 301, created_at: 3.days.ago, network: network)
      create(:epoch_wall_clock, epoch: 302, network: network)

      cluster_stat = ClusterStat.by_network(network).last
      cluster_stat.update(epoch_duration: 0)

      ClusterStats::UpdateEpochDurationService.new(network).call

      assert_equal 259200.0, cluster_stat.reload.epoch_duration
    end

    test "creates cluster stat if it doesn't exist" do
      ClusterStats::UpdateEpochDurationService.new(@network).call

      assert ClusterStat.by_network(@network).exists?
    end
  end
end

