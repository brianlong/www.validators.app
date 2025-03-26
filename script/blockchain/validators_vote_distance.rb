EPOCH = 686

validators_votes = {}
total_batches = Blockchain::MainnetTransaction.where(epoch: EPOCH).count / 5000
Blockchain::MainnetTransaction.where(epoch: EPOCH).find_in_batches(batch_size: 5000).with_index do |tx_batch, batch_index|
    puts "Processing batch #{batch_index + 1} / #{total_batches + 1}"
    tx_batch.each do |tx|
        validators_votes[tx.account_key_1] = validators_votes[tx.account_key_1] ? validators_votes[tx.account_key_1] + 1 : 1
    end
end

CSV.open("#{Rails.root}/tmp/validator_votes.csv", "w") do |csv|
    csv << %w[validator_key votes]
    validators_votes.sort_by { |k, v| v }.reverse.to_h.each do |k, v|
        csv << [k, v]
    end
end

v_csv = CSV.read("#{Rails.root}/tmp/validator_votes.csv")

v_csv.each do |row|
  validator = Validator.find_by(account: row[0])
  if validator && validator.score && validator.score.stake_concentration
    row[2] = (validator.score.stake_concentration * 100).round(3).to_s + "%"
  end
end

CSV.open("#{Rails.root}/tmp/validator_votes.csv", "w") do |csv|
  v_csv.each do |row|
    csv << row
  end
end