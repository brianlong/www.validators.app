# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/prune_database_tables.rb
require File.expand_path('../config/environment', __dir__)

sixty_days_ago = (Date.today - 60.days).to_s(:db)

%w[
  batches
  epoch_histories
  ping_time_stats
  ping_times
  reports
  validator_block_histories
  validator_block_history_stats
  validator_histories
  vote_account_histories
  vote_account_stake_histories
  explorer_stake_account_history_stats
].each do |table|
  sql = "DELETE FROM #{table} WHERE created_at < '#{sixty_days_ago}';"
  ActiveRecord::Base.connection.execute(sql)
end

# Remove old validators that are not active after 60 days
NETWORKS.each do |network|
  ValidatorScoreV1.where("active_stake = 0 and created_at < '#{sixty_days_ago}' and network = '#{network}'")
                  .each do |score|
                    if score.validator && score.validator.vote_account_histories.count > 0
                      puts "  Skipping due to non-empty vote_account_histories"
                      next
                    end
                    # score.validator.vote_account_histories.destroy_all
                    # score.validator.vote_accounts
                    score.validator&.destroy
                  end

  ValidatorScoreV1.where("active_stake IS NULL and created_at < '#{sixty_days_ago}' and network = '#{network}'")
                  .each do |score|
                    if score.validator && score.validator.vote_account_histories.count > 0
                      puts "  Skipping due to non-empty vote_account_histories"
                      next
                    end
                    # score.validator.vote_account_histories.destroy_all
                    # score.validator.vote_accounts
                    score.validator&.destroy
                  end
end

# remove old audit records (from explorer stake accounts)
Audited::Audit.where("created_at < ?", sixty_days_ago).in_batches(of: 1000) do |batch|
  batch.delete_all
end
