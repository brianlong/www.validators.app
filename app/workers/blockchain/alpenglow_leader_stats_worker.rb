# frozen_string_literal: true

module Blockchain
  class AlpenglowLeaderStatsWorker
    include Sidekiq::Worker
    sidekiq_options retry: 0, dead: false, lock: :until_executed, queue: :default

    def perform(args = {})
      return if Rails.env.stage?

      Blockchain::AlpenglowLeaderStatsService.new(network: args["network"]).call
    end
  end
end
