# frozen_string_literal: true

require Rails.root.join("daemons", "concerns", "leader_stats_helper")

module Blockchain
  class LeaderStatsUpdateWorker
    include Sidekiq::Worker
    include LeaderStatsHelper
    sidekiq_options retry: 0, dead: false, lock: :until_executed

    def perform(args = {})
      network = args["network"]

      leaders = { network => leaders_for_network(network) }
      ActionCable.server.broadcast("leaders_channel", leaders)
    end
  end
end
