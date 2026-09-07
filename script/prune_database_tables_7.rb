# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/prune_database_tables.rb
require File.expand_path('../config/environment', __dir__)

seven_days_ago = (Date.today - 7.days).to_s(:db)

verbose = false
puts seven_days_ago if verbose

[
  Batch,
  EpochHistory,
  PingTimeStat,
  PingTime,
  Report,
  ValidatorBlockHistory,
  ValidatorBlockHistoryStat,
  ValidatorHistory,
  VoteAccountHistory
].each do |klass|
  puts "DELETE FROM #{klass.table_name} WHERE created_at < '#{seven_days_ago}'" if verbose
  klass.where("created_at < ?", seven_days_ago).in_batches(of: 1000) do |batch|
    batch.delete_all
  end
end

# Remove old validators that are not active after 30 days
ValidatorScoreV1.where("active_stake = 0 and created_at < '#{seven_days_ago}'")
                .each do |score|
                  puts "#{score.validator.account} (#{score.network})" \
                    if verbose
                  if score.validator.vote_account_histories.count > 0
                    puts '  Skipping due to non-empty vote_account_histories'
                    next
                  end
                  # score.validator.vote_account_histories.destroy_all
                  # score.validator.vote_accounts
                  score.validator.destroy
                end

ValidatorScoreV1.where("active_stake IS NULL and created_at < '#{seven_days_ago}'")
                .each do |score|
                  puts "#{score.validator.account} (#{score.network})" \
                    if verbose
                  if score.validator.vote_account_histories.count > 0
                    puts '  Skipping due to non-empty vote_account_histories'
                    next
                  end
                  # score.validator.vote_account_histories.destroy_all
                  # score.validator.vote_accounts
                  score.validator.destroy
                end
