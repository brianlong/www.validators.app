module Blockchain
  class VoteLatencyScoreWorker
    include Sidekiq::Worker
    sidekiq_options retry: 0, dead: false, lock: :until_executed


    def perform(args = {})
      network = args["network"]

      Blockchain::SetVoteLatencyScore.new(network).call
    end
  end
end