EPOCH = 686

validators_active_blocks = {}

Blockchain::MainnetBlock.where(epoch: EPOCH).each do |block|
  puts "Processing block #{block.slot_number}"
  block.transactions.each do |tx|
    validators_active_blocks[tx.account_key_1] = validators_active_blocks[tx.account_key_1] ? validators_active_blocks[tx.account_key_1].push(block.slot_number) : [block.slot_number]
  end
end

validators_gaps = {}
validators_active_blocks.map do |k, v|
    validators_gaps[k] = v.each_cons(2).map { |a, b| b - a }.max
end

CSV.open("#{Rails.root}/tmp/validator_vote_gaps.csv", "w") do |csv|
    csv << %w[validator_key gap]
    validators_gaps.sort_by { |k, v| v }.reverse.to_h.each do |k, v|
        csv << [k, v]
    end
end