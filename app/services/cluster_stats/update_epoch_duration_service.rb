# frozen_string_literal: true

module ClusterStats
  class UpdateEpochDurationService

    AVG_EPOCH_SIZE = 5

    def initialize(network)
      @network = network
    end

    def call
      cluster_stat.update_attribute(:epoch_duration, epoch_duration)

      cluster_stat
    end

    private

    attr_reader :network

    def cluster_stat
      ClusterStat.find_or_create_by(network: network)
    end

    def epochs
      @epochs ||= EpochWallClock.by_network(network).last(AVG_EPOCH_SIZE)
    end

    def epoch_duration
      (epochs.last.created_at - epochs.first.created_at.to_f) / AVG_EPOCH_SIZE
    end
  end
end
