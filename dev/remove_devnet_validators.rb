# frozen_string_literal: true

VALIDATORS_TO_REMOVE = %w[
  dv1ZAGvdsz5hHLwWXsVnM94hWf1pjbKVau1QVkaMJ92
].freeze

# dv2eQHeP4RFrJZ6UeiZWoc3XTtmtZCUKxxCApCDcRNV
# dv3qDFk1DTF36Z62bNvrCXe9sKATA6xvVy6A798xxAS
# dv4ACNkpYPcE3aKmYDqZm9G5EB3J4MRoeE7WNDRBVJB

VALIDATORS_TO_REMOVE.each do |account|
  puts "-----------------"
  validator = Validator.find_by(account: account)
  puts "found validator with id: #{validator.id}"

  validator.validator_histories.delete_all
  puts "validator_histories deleted"

  validator.validator_block_histories.delete_all
  puts "validator_block_histories deleted"

  vote_accounts = validator.vote_accounts
  vote_accounts.each do |va| 
    if va.vote_account_histories.any?
      va.vote_account_histories.delete_all
    end
  end
  puts "vote_account_histories deleted"

  validator.vote_accounts.delete_all
  puts "vote_accounts deleted"

  validator.commission_histories.delete_all
  puts "commission_histories deleted"

  StakeAccountHistory.where(validator_id: validator.id).delete_all
  puts "stake_account_histories deleted"

  StakeAccount.where(validator_id: validator.id).delete_all
  puts "stake_accounts deleted"

  validator.validator_ips.delete_all
  puts "ips deleted"

  validator.validator_score_v1.delete
  puts "score deleted"
end
