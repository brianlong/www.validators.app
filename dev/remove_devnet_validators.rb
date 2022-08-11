# frozen_string_literal: true

network = ARGV[0]
account = ARGV[1]

raise "invalid network - #{network}" unless %w(mainnet testnet).include? network

validator = Validator.find_by(account: account, network: network)

raise "validator not found (#{account})" unless validator

puts "found validator with id: #{validator.id}"

validator.validator_histories.delete_all
puts "validator_histories deleted"

validator.validator_block_histories.delete_all
puts "validator_block_histories deleted"

vote_accounts = validator.vote_accounts
vote_accounts.each do |va| 
  if va.vote_account_histories.any?
    va.vote_account_histories.map(&:delete)
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

validator.validator_ips&.delete_all
puts "ips deleted"

validator.validator_score_v1&.delete
puts "score deleted"

validator.delete
puts "validator deleted"
