# frozen_string_literal: true

require Rails.root.join("daemons", "concerns", "leader_stats_helper")

module Blockchain
  class LeaderStatsUpdateWorker
    include Sidekiq::Worker
    include LeaderStatsHelper
    # scope the lock to the network only (not slot_number) so at most one job per
    # network is ever queued/running; a newer slot notification replaces the
    # still-queued one instead of piling up behind a slow RPC call
    sidekiq_options retry: 0,
                     dead: false,
                     lock: :until_executed,
                     lock_args_method: ->(args) { [args.first["network"]] },
                     on_conflict: :replace

    def perform(args = {})
      network = args["network"]

      leaders = { network => leaders_for_network(network) }
      ActionCable.server.broadcast("leaders_channel", leaders)
    end
  end
end
