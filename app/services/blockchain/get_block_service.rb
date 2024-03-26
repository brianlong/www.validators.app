#frozen_string_literal: true

module Blockchain
  class GetBlockService
    include SolanaRequestsLogic


    def initialize(network, slot_number, config_urls = nil)
      @network = network
      @slot_number = slot_number
      @config_urls = config_urls || Rails.application.credentials.solana["#{network}_urls".to_sym]
    end

    def call
      block = solana_client_request(
        @config_urls,
        :get_block,
        params: [@slot_number, {}]
      )
      block = {
        height: block["blockHeight"],
        block_time: block["blockTime"],
        hash: block["blockhash"],
        parent_slot: block["parentSlot"]
      }
      Block.create!(block)
    end
  end
end
