module Blockchain
  class SetVoteLatencyScore

    class NoBlocksError < StandardError; end

    def initialize(network)
      @network = network
      @blockcs_distances = {}
      @blocks = nil
      @validators_latencies = {}
    end

    def call
      start_time = Time.now
      @blocks = get_blocks
      fill_validators_latencies
      set_average_latencies_for_validators
      save_vote_latency
      end_time = Time.now
      puts "Time taken to set vote latency score: #{end_time - start_time} seconds"
    end

    # get all blocks fromt last hour that are not processed
    def get_blocks
      puts "searching #{@network} blocks"
      @blocks = Blockchain::Block.network(@network).where("created_at > ? AND processed IS FALSE", 3.hours.ago)
    end

    def fill_validators_latencies
      @blocks.each do |block|
        @blockcs_distances = {} # reset block distances for each block
        block.transactions.each do |transaction|
          val = transaction.account_key_1
          block_distance = get_block_distance(transaction.recent_blockhash, block.slot_number)

          if @validators_latencies[val].present?
            @validators_latencies[val].push(block_distance)
          else
            @validators_latencies[val] = [block_distance]
          end
        rescue NoBlocksError
          puts "No blocks found for blockhash: #{transaction.recent_blockhash}"
          next
        end
      end
      @blocks.update_all(processed: true)
    end

    def get_block_distance(blockhash, current_slot_number)
      return @blockcs_distances[blockhash] if @blockcs_distances[blockhash].present?

      block = Blockchain::Block.network(@network).find_by(blockhash: blockhash)
      raise NoBlocksError if block.blank?
      block_slot_number = block.slot_number
      block_distance = current_slot_number - block_slot_number
      @blockcs_distances[blockhash] = block_distance
    end

    def set_average_latencies_for_validators
      @validators_latencies.each do |validator, latencies|
        avg_latency = (latencies.sum.to_f / latencies.size).round(2)
        @validators_latencies[validator] = avg_latency
      end
    end

    def save_vote_latency
      puts "Saving vote latency scores"
      @validators_latencies.each do |validator, avg_latency|
        v = Validator.find_by(account: validator, network: @network)
        next if v.blank?
        v.score.vote_latency_history_push(avg_latency)
        v.score.save
      end
    end

  end
end