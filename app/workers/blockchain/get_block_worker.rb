# frozen_string_literal: true

module Blockchain
  class GetBlockWorker
    include Sidekiq::Worker
    sidekiq_options retry: 0, dead: false, lock: :until_executed

    def perform(args = {})
      network = args["network"]
      slot_number = args["slot_number"]

      GetBlockService.new(network, slot_number).call
    end
  end
end
