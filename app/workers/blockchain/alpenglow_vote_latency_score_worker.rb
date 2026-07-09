# frozen_string_literal: true

module Blockchain
  class AlpenglowVoteLatencyScoreWorker
    include Sidekiq::Worker
    sidekiq_options retry: 0, dead: false, lock: :until_executed, queue: :default

    def perform(args = {})
      network = args["network"]

      Blockchain::SetAlpenglowVoteLatencyScore.new(network).call
    end
  end
end
