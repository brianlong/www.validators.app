# frozen_string_literal: true

module ClusterStats
  class UpdateEpochDurationService

    NUMBER_OF_EPOCHS = 6

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
      @epochs ||= EpochWallClock.by_network(network).first(NUMBER_OF_EPOCHS)
    end

    def epoch_duration
      diff = (epochs.first.created_at - epochs.last.created_at)
      return diff if epochs.size == 2

      diff / epochs.size
    end
  end
end
