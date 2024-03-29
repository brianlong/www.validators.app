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
      puts block["blockHeight"]
      puts block["blockTime"]
      puts block["blockhash"]
      puts block["parentSlot"]
      
      Blockchain::Block.create(
        height: block["blockHeight"].to_i,
        block_time: block["blockTime"].to_i,
        blockhash: block["blockhash"],
        parent_slot: block["parentSlot"].to_i,
        slot_number: @slot_number
      )
      update_slot_status
    end

    def update_slot_status
      puts "updating slot status"
      slot = Slot.find_by(slot_number: @slot_number, network: @network)
      slot&.has_block!
    end
  end
end
