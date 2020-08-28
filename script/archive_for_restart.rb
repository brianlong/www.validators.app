# frozen_string_literal: true

# Use this script to archive data if we need to restart testnet.
#
# RAILS_ENV=production bundle exec ruby script/archive_for_restart.rb
require File.expand_path('../config/environment', __dir__)

verbose = true
network = 'testnet'
today = Date.today.strftime('%Y%m%d')
puts "Archiving data for #{network} #{today}"

%w[batches epoch_histories feed_zones reports validator_block_histories validator_block_history_stats validator_histories vote_account_histories].each do |table|
  # Create the restart archive table
  archive_table = "#{table}_restart_#{today}"
  ddl = "CREATE TABLE IF NOT EXISTS #{archive_table} LIKE #{table}"
  puts ddl if verbose
  ActiveRecord::Base.connection.execute(ddl)

  # Insert the data for this network into the restart table
  sql_insert = "REPLACE INTO #{archive_table}
                SELECT *
                FROM #{table}
                WHERE network = '#{network}'"
  ActiveRecord::Base.connection.execute(sql_insert)

  # Show the count
  sql_count = "SELECT count(id) as count from #{archive_table}"
  count = ActiveRecord::Base.connection.execute(sql_count).first.first
  puts "  #{count} records" if verbose

  # Delete from the source table for this network
  sql_delete = "DELETE FROM #{table} WHERE network = '#{network}'"
  ActiveRecord::Base.connection.execute(sql_delete)
end
