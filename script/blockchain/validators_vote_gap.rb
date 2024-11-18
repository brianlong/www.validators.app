EPOCH = 697
EPOCH_START = 297648000

validators_active_blocks = {}
validators_data = {}
total_batches = Blockchain::MainnetBlock.where(epoch: EPOCH).count / 100

Blockchain::MainnetBlock.where(epoch: EPOCH).find_in_batches(batch_size: 100).with_index do |batch, batch_index|
    batch.each do |block|
        print "\r#{batch_index + 1} / #{total_batches + 1}"
        block.transactions.each do |tx|
            if tx.recent_blockhash
                recent_block_height = Blockchain::MainnetBlock.find_by(blockhash: tx.recent_blockhash)&.height
                if recent_block_height
                    block_latency = block.height - recent_block_height 
                    validators_data[tx.account_key_2] = validators_data[tx.account_key_2] ? validators_data[tx.account_key_2].push(block_latency) : [block_latency]
                end
            end
        end
    end
end

# validators_gaps = {}
# validators_active_blocks.map do |k, v|
#     validator_rewards = VoteAccount.find_by(account: k).validator.validator_histories.where(epoch: EPOCH).last.credits rescue nil
#     validators_data[k] = {
#         vote_count: validators_data[k][:vote_count],
#         gap: v.each_cons(2).map { |a, b| b - a }.max,
#         rewards: validator_rewards,
#         rewards_ratio: (validator_rewards / validators_data[k][:vote_count] rescue nil)
#     }
# end

CSV.open("#{Rails.root}/tmp/validator_vote_gaps.csv", "w") do |csv|
    csv << %w[vote_account slot_latency]
    validators_data.each do |k, v|
        csv << [k, (v.inject{ |sum, el| sum + el }.to_f / v.size).round(2)]
    end
end