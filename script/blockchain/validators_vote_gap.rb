EPOCH = 693
EPOCH_START = 297648000

validators_active_blocks = {}
validators_data = {}
# Blockchain::MainnetBlock.where(epoch: EPOCH).find_in_batches(batch_size: 100) do |batch|
#     batch.each do |block|
#         puts "Processing block #{block.slot_number}"
#         block.transactions.each do |tx|
#             validators_active_blocks[tx.account_key_1] = validators_active_blocks[tx.account_key_1] ? validators_active_blocks[tx.account_key_1].push(block.slot_number) : [block.slot_number]
#             if validators_data[tx.account_key_1] 
#                 validators_data[tx.account_key_1][:vote_count] = validators_data[tx.account_key_1][:vote_count] ? validators_data[tx.account_key_1][:vote_count] + 1 : 1
#             else
#                 validators_data[tx.account_key_1] = {vote_count: 1}
#             end
#         end
#     end
# end

# validators_gaps = {}
# validators_active_blocks.map do |k, v|
#     validator_rewards = Validator.find_by(account: k).validator_histories.where(epoch: EPOCH).last.credits rescue nil
#     validators_data[k] = {
#         vote_count: validators_data[k][:vote_count],
#         gap: v.each_cons(2).map { |a, b| b - a }.max,
#         rewards: validator_rewards,
#         rewards_ratio: (validator_rewards / validators_data[k][:vote_count] rescue nil)
#     }
# end

# CSV.open("#{Rails.root}/tmp/validator_vote_gaps.csv", "w") do |csv|
#     csv << %w[validator_key vote_count gap rewards rewards_ratio]
#     validators_data.sort_by{ |k, v| v[:rewards_ratio] || 0 }.reverse.to_h.each do |k, v|
#         csv << [k, v[:vote_count], v[:gap], v[:rewards], v[:rewards_ratio]]
#     end
# end

Blockchain::MainnetBlock.where(epoch: EPOCH).find_in_batches(batch_size: 100) do |batch|
    batch.each do |block|
        puts "Processing block #{block.slot_number}"
        block.transactions.each do |tx|
            validators_active_blocks[tx.account_key_2] = validators_active_blocks[tx.account_key_2] ? validators_active_blocks[tx.account_key_2].push(block.slot_number) : [block.slot_number]
            if validators_data[tx.account_key_2] 
                validators_data[tx.account_key_2][:vote_count] = validators_data[tx.account_key_2][:vote_count] ? validators_data[tx.account_key_2][:vote_count] + 1 : 1
            else
                validators_data[tx.account_key_2] = {vote_count: 1}
            end
        end
    end
end

validators_gaps = {}
validators_active_blocks.map do |k, v|
    validator_rewards = Validator.find_by(account: k).validator_histories.where(epoch: EPOCH).last.credits rescue nil
    validators_data[k] = {
        vote_count: validators_data[k][:vote_count],
        gap: v.each_cons(2).map { |a, b| b - a }.max,
        rewards: validator_rewards,
        rewards_ratio: (validator_rewards / validators_data[k][:vote_count] rescue nil)
    }
end

CSV.open("#{Rails.root}/tmp/validator_vote_gaps.csv", "w") do |csv|
    csv << %w[validator_key vote_count gap rewards rewards_ratio]
    validators_data.sort_by{ |k, v| v[:rewards_ratio] || 0 }.reverse.to_h.each do |k, v|
        csv << [k, v[:vote_count], v[:gap], v[:rewards], v[:rewards_ratio]]
    end
end