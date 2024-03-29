# frozen_string_literal: true

module Blockchain
  class GetBlockWorker
    include Sidekiq::Worker
    include AsnLogic

    def perform(args = {})
      network = args["network"]
      slot_number = args["slot_number"]

      GetBlockService.new(network, slot_number).call
    end
  end
end
