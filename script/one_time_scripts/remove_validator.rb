# frozen_string_literal: true

@network ||= ARGV[0]
@account ||= ARGV[1]

# raise "invalid network - #{network}" unless NETWORKS.include? network

validator = Validator.find_by(account: @account, network: @network)

raise "validator not found (#{@account})" unless validator

puts "found validator with id: #{validator.id}"

ActiveRecord::Base.transaction do
  validator.validator_histories.delete_all
  validator.validator_block_histories.delete_all

  validator.vote_accounts.each do |va|
    va.account_authority_histories.map(&:delete)
    va.vote_account_histories.map(&:delete)
  end

  validator.vote_accounts.delete_all
  validator.commission_histories.delete_all
  validator.stake_account_histories.delete_all
  validator.stake_accounts.delete_all
  validator.validator_ips.delete_all
  validator.validator_score_v1&.delete
  validator.user_watchlist_elements.delete_all
  validator.delete

  unless Rails.env.test?
    puts "validator_histories deleted"
    puts "validator_block_histories deleted"
    puts "account_authority_histories deleted"
    puts "vote_account_histories deleted"
    puts "vote_accounts deleted"
    puts "commission_histories deleted"
    puts "stake_account_histories deleted"
    puts "stake_accounts deleted"
    puts "ips deleted"
    puts "score deleted"
    puts "user_watchlist_elements deleted"
    puts "validator deleted"
  end
rescue StandardError => e
  puts e.message
end
