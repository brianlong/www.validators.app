# frozen_string_literal: true

require "test_helper"

module ClusterStats
  class UpdateEpochDurationServiceTest < ActiveSupport::TestCase
    setup do
      @network = "testnet"

      create(:epoch_wall_clock, epoch: 301, created_at: 16.days.ago)
      create(:epoch_wall_clock, epoch: 302, created_at: 13.days.ago)
      create(:epoch_wall_clock, epoch: 303, created_at: 10.days.ago)
      create(:epoch_wall_clock, epoch: 304, created_at: 7.days.ago)
      create(:epoch_wall_clock, epoch: 305, created_at: 4.days.ago)
      create(:epoch_wall_clock, epoch: 306, created_at: 1.day.ago)
    end

    test "updates epoch duration" do
      cluster_stat = ClusterStat.last
      cluster_stat.update(epoch_duration: 0)

      ClusterStats::UpdateEpochDurationService.new(@network).call

      assert_equal 207360.0, cluster_stat.reload.epoch_duration
    end

    test "creates cluster stat if it doesn't exist" do
      ClusterStats::UpdateEpochDurationService.new(@network).call

      assert ClusterStat.by_network(@network).exists?
    end
  end
end

