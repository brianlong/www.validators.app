# frozen_string_literal: true

module Blockchain
  class AlpenglowEpochRanksWorker
    include Sidekiq::Worker
    sidekiq_options retry: 0, dead: false, lock: :until_executed, queue: :default

    def perform(args = {})
      Blockchain::AlpenglowEpochRanksService.new(network: args["network"]).call
    end
  end
end
