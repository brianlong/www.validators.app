# frozen_string_literal: true

# rails runner script/one_time_scripts/remove_validator.rb NETWORK ACCOUNT

@network ||= ARGV[0]
@account ||= ARGV[1]

raise "invalid network - #{@network}" unless NETWORKS.include? @network
raise "validator account is missing" if @account.blank?

validator = Validator.find_by(account: @account, network: @network)

raise "validator not found (#{@account})" unless validator

puts "found validator with id: #{validator.id}"

validator.validator_histories.delete_all
puts "validator_histories deleted"

validator.validator_block_histories.delete_all
puts "validator_block_histories deleted"

validator.vote_accounts.each do |va|
  va.account_authority_histories.map(&:delete)
  puts "account_authority_histories deleted"

  va.vote_account_histories.map(&:delete)
  puts "vote_account_histories deleted"
end

validator.vote_accounts.delete_all
puts "vote_accounts deleted"

validator.commission_histories.delete_all
puts "commission_histories deleted"

validator.stake_account_histories.delete_all
puts "stake_account_histories deleted"

validator.stake_accounts.delete_all
puts "stake_accounts deleted"

validator.validator_ips.delete_all
puts "ips deleted"

validator.validator_score_v1&.delete
puts "score deleted"

validator.user_watchlist_elements.delete_all
puts "user_watchlist_elements deleted"

validator.delete
puts "validator deleted"
