# frozen_string_literal: true

require "test_helper"

module ClusterStats
  class UpdateEpochDurationServiceTest < ActiveSupport::TestCase
    setup do
      @network = "testnet"

      create(:epoch_wall_clock, epoch: 301, created_at: 16.days.ago)
      create(:epoch_wall_clock, epoch: 311, created_at: 13.days.ago)
      create(:epoch_wall_clock, epoch: 322, created_at: 10.days.ago)
      create(:epoch_wall_clock, epoch: 333, created_at: 7.days.ago)
      create(:epoch_wall_clock, epoch: 344, created_at: 4.days.ago)
      create(:epoch_wall_clock, epoch: 355, created_at: 1.day.ago)
    end

    test "updates epoch duration" do
      cluster_stat = create(:cluster_stat, network: @network)

      ClusterStats::UpdateEpochDurationService.new(@network).call

      assert_equal 207360.0, cluster_stat.reload.epoch_duration
    end

    test "creates cluster stat if it doesn't exist" do
      ClusterStats::UpdateEpochDurationService.new(@network).call

      assert ClusterStat.by_network(@network).exists?
    end
  end
end

