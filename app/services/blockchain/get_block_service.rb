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
        params: [@slot_number, { encoding: "jsonParsed", maxSupportedTransactionVersion: 0 }]
      )
      if @block[:error]
        if @block[:error].include?("429")
          Appsignal.send_error( StandardError.new(@block[:error]) )
        end
        update_slot_status(status: "request_error")
      else
        save_block
        if process_transactions
          update_slot_status(status: "has_block")
        else
          # if transaction processing failed, destroy block and let it be processed again later
          destroy_block
        end
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

    def destroy_block
      @saved_block.transactions.destroy_all
      @saved_block.destroy
    end

    def process_transactions
      if @block["transactions"]
        vote_txs = @block["transactions"].select do |tx| 
          tx.dig("transaction", "message", "accountKeys")&.any? { |key| 
            key.is_a?(Hash) ? key["pubkey"] == "Vote111111111111111111111111111111111111111" : key == "Vote111111111111111111111111111111111111111"
          }
        end
        vote_txs.in_groups_of(1000) do |group|
          batch = group.compact.map do |tx|
            message = tx["transaction"]["message"]
            account_keys = extract_account_keys(message)
            voted_slot = extract_voted_slot(message)
            {
              account_key_1: account_keys[0],
              account_key_2: account_keys[1],
              account_key_3: account_keys[2],
              recent_blockhash: voted_slot.to_s,
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
          if batch.any?
            begin
              Blockchain::Transaction.network(@network).insert_all(batch)
            rescue ActiveRecord::ConnectionTimeoutError, ActiveRecord::Deadlocked, ActiveRecord::LockWaitTimeout
              return false
            end
          end
        end
      end
      true
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

    # Extract account keys from message (handles both legacy and jsonParsed formats)
    def extract_account_keys(message)
      account_keys = message["accountKeys"]
      if account_keys.first.is_a?(Hash)
        account_keys.map { |key| key["pubkey"] }
      else
        account_keys
      end
    end

    # Extract voted slot from vote instruction
    # Vote instructions contain the slot(s) being voted on
    # Supports both "vote" and "towersync" instruction types
    def extract_voted_slot(message)
      instructions = message["instructions"]
      return nil unless instructions

      instructions.each do |instruction|
        if instruction.is_a?(Hash) && instruction["parsed"]
          parsed = instruction["parsed"]

          if parsed["type"] == "vote" && parsed["info"]
            votes = parsed["info"]["votes"]
            return votes.last["slot"] if votes&.any?
          end
          
          if parsed["type"] == "towersync" && parsed["info"]
            tower_sync_data = parsed["info"]["towerSync"]
            if tower_sync_data.is_a?(Hash) && tower_sync_data["lockouts"]
              lockouts = tower_sync_data["lockouts"]
              if lockouts.is_a?(Array) && lockouts.any?
                voted_slot = lockouts.last["slot"]
                return voted_slot
              end
            end
          end
        end
      end
      
      nil
    end
  end
end
