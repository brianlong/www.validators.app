# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/prune_database_tables.rb
require File.expand_path('../config/environment', __dir__)

sixty_days_ago = (Date.today - 60.days).to_s(:db)

verbose = false
puts sixty_days_ago if verbose

%w[batches epoch_histories ping_time_stats ping_times reports validator_block_histories validator_block_history_stats validator_histories vote_account_histories cluster_stats].each do |table|
  sql = "DELETE FROM #{table} WHERE created_at < '#{sixty_days_ago}';"
  puts sql if verbose
  ActiveRecord::Base.connection.execute(sql)
end

# delete cluster stats report older than 5 days
Report.where(name: "report_cluster_stats").where("created_at < ?", 5.days.ago).delete_all

# Remove old validators that are not active after 60 days
ValidatorScoreV1.where("active_stake = 0 and created_at < '#{sixty_days_ago}'")
                .each do |score|
                  puts "#{score.validator.account} (#{score.network})" \
                    if verbose
                  if score.validator.vote_account_histories.count > 0
                    puts "  Skipping due to non-empty vote_account_histories"
                    next
                  end
                  # score.validator.vote_account_histories.destroy_all
                  # score.validator.vote_accounts
                  score.validator.destroy
                end

ValidatorScoreV1.where("active_stake IS NULL and created_at < '#{sixty_days_ago}'")
                .each do |score|
                  puts "#{score.validator.account} (#{score.network})" \
                    if verbose
                  if score.validator.vote_account_histories.count > 0
                    puts "  Skipping due to non-empty vote_account_histories"
                    next
                  end
                  # score.validator.vote_account_histories.destroy_all
                  # score.validator.vote_accounts
                  score.validator.destroy
                end
