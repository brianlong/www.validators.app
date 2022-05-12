# frozen_string_literal: true

VALIDATORS_TO_REMOVE = %w[
  dv1ZAGvdsz5hHLwWXsVnM94hWf1pjbKVau1QVkaMJ92
  dv2eQHeP4RFrJZ6UeiZWoc3XTtmtZCUKxxCApCDcRNV
  dv3qDFk1DTF36Z62bNvrCXe9sKATA6xvVy6A798xxAS
  dv4ACNkpYPcE3aKmYDqZm9G5EB3J4MRoeE7WNDRBVJB
].freeze

VALIDATORS_TO_REMOVE.each do |account|
  validator = Validator.find_by(account: account)
  puts "found validator with id: #{validator.id}"

  validator.validator_histories.delete_all
  puts "validator_histories deleted"
  
  validator.validator_block_histories.delete_all

  vote_accounts = validator.vote_accounts
  vote_accounts.each { |va| va.vote_account_histories.delete_all }

  validator.commission_histories.delete_all

  StakeAccountHistory.where(validator_id: validator.id).delete_all
  StakeAccount.where(validator_id: validator.id).delete_all

  validator.validator_ips.delete_all
  validator.validator_score_v1.delete
end
