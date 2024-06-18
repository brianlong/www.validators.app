# frozen_string_literal: true

module Blockchain
  class GetBlockService

    def initialize(network, slot_number, config_urls = nil)
      @network = network
      @slot_number = slot_number
      @config_urls = config_urls || Rails.application.credentials.solana["#{network}_urls".to_sym]
      @block = {}
      @saved_block = nil
      @slot = Slot.network(@network).find_by(slot_number: @slot_number)
    end

    def call
      @block = solana_client_request(
        @config_urls,
        :get_block,
        params: [@slot_number, {}]
      )
      if @block[:error]
        if @block[:error].include?("429")
          Appsignal.send_error( StandardError.new(@block[:error]) )
        end
        update_slot_status(status: "request_error")
      else
        save_block
        process_transactions
        update_slot_status(status: "has_block")
      end
    end

    # available statuses: has_block, request_error, no_block, initialized
    def update_slot_status(status:)
      case status
      when "has_block"
        @slot.update(status: "has_block")
      when "request_error"
        # if slot status was previously request_error, this means it has no block
        if @slot.status == "request_error"
          @slot.update(status: "no_block")
        else
          @slot.update(status: "request_error")
        end
      else
        @slot.update(status: status)
      end
    end

    def save_block
      @saved_block = Blockchain::Block.network(@network).create(
        height: @block["blockHeight"].to_i,
        block_time: @block["blockTime"].to_i,
        blockhash: @block["blockhash"],
        parent_slot: @block["parentSlot"].to_i,
        slot_number: @slot_number,
        epoch: @slot.epoch
      )
    end

    def process_transactions
      if @block["transactions"]
        vote_txs = @block["transactions"].select do |tx| 
          tx["transaction"]["message"]["accountKeys"].include?("Vote111111111111111111111111111111111111111")
        end
        vote_txs.in_groups_of(50) do |group|
          batch = group.compact.map do |tx|
            {
              account_key_1: tx["transaction"]["message"]["accountKeys"][0],
              account_key_2: tx["transaction"]["message"]["accountKeys"][1],
              account_key_3: tx["transaction"]["message"]["accountKeys"][2],
              fee: tx["meta"]["fee"],
              post_balances: tx["meta"]["postBalances"],
              pre_balances: tx["meta"]["preBalances"],
              slot_number: @slot_number,
              block_id: @saved_block.id,
              epoch: @slot.epoch,
              created_at: Time.now,
              updated_at: Time.now
            }
          end
          Blockchain::Transaction.network(@network).insert_all(batch) if batch.any?
        end
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
        return { error: e.message }
      end
    end
  end
end
