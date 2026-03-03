# frozen_string_literal: true

module Blockchain
  class SetVoteLatencyScore

    def initialize(network)
      @network = network
      @blocks_slot_numbers = {}
      @blocks = nil
      @validators_latencies = {}
    end

    def call
      @blocks = get_blocks
      fill_validators_latencies
      set_average_latencies_for_validators
      save_vote_latency
    end

    # get all blocks from the last hour that are not processed
    def get_blocks
      @blocks = Blockchain::Block.network(@network).where("created_at > ? AND processed IS FALSE", 15.minutes.ago)
    end

    def fill_validators_latencies
      @blocks.each_with_index do |block, index|
        @blocks_slot_numbers[block.blockhash] = block.slot_number
        block.transactions.each do |transaction|
          val = transaction.account_key_1

          next if transaction.recent_blockhash.blank?

          voted_slot = transaction.recent_blockhash.to_i
          next if voted_slot == 0 && transaction.recent_blockhash != "0"
          
          block_distance = block.slot_number - voted_slot

          if @validators_latencies[val].present?
            @validators_latencies[val].push(block_distance)
          else
            @validators_latencies[val] = [block_distance]
          end
        end
        block.update(processed: true)
      end
    end

    def set_average_latencies_for_validators
      @validators_latencies.each do |validator, latencies|
        avg_latency = (latencies.sum.to_f / latencies.size).round(2)
        @validators_latencies[validator] = avg_latency
      end
    end

    def save_vote_latency
      @validators_latencies.each do |validator, avg_latency|
        v = Validator.find_by(account: validator, network: @network)
        next if v.blank?
        
        v.score.vote_latency_history_push(avg_latency)
        v.score.save
        v.vote_account_active.vote_account_histories.last.update(vote_latency_average: avg_latency) rescue next
      end
    end
  end
end
