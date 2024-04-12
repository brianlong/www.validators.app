#frozen_string_literal: true

module Blockchain
  class GetBlockService

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
      if block[:error]
        update_slot_status(status: "request_error")
      else
        Blockchain::Block.create(
          height: block["blockHeight"].to_i,
          block_time: block["blockTime"].to_i,
          blockhash: block["blockhash"],
          parent_slot: block["parentSlot"].to_i,
          slot_number: @slot_number
        )
        update_slot_status
      end
    end

    # available statuses: has_block, request_error, no_block, initialized
    def update_slot_status(status: "has_block")
      slot = Slot.find_by(slot_number: @slot_number, network: @network)
      case status
      when "has_block"
        slot.update(status: "has_block")
      when "request_error"
        # if slot status was previously request_error, this means it has no block
        if slot.status == "request_error"
          slot.update(status: "no_block")
        else
          slot.update(status: "request_error")
        end
      else
        slot.update(status: status)
      end
    end

    # solana client request with changed error handling
    def solana_client_request(clusters, method, params:)
      clusters.each do |cluster_url|
        client = SolanaRpcClient.new(cluster: cluster_url).client
        response = client.public_send(method, params.first, **params.last).result
        return response unless response.blank?
      rescue SolanaRpcRuby::ApiError => e
        puts e.message
        return {error: e.message}
      end
    end
  end
end
