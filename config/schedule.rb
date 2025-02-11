# frozen_string_literal: true

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :bundle_bin, '/usr/bin/bundle'
set :ruby_bin, '/usr/bin/ruby'
set :rake_bin, '/usr/bin/rake'
set :environment, (ENV['RAILS_ENV'] || @environment).to_s
set :whenever_path, Whenever.path

set :output, File.join(Whenever.path, 'log', 'whenever.log')
job_type :ruby_script,
         'cd :path && RAILS_ENV=:environment :bundle_bin exec :ruby_bin script/:task >> :whenever_path/log/:task.log 2>&1'
job_type :ruby_script_sol_prices,
         'cd :path && RAILS_ENV=:environment :bundle_bin exec :ruby_bin script/sol_prices/:task >> :whenever_path/log/:task.log 2>&1'
job_type :ruby_script_data_centers,
         'cd :path && RAILS_ENV=:environment :bundle_bin exec :ruby_bin script/data_centers_scripts/:task >> :whenever_path/log/:task.log 2>&1'
job_type :ruby_script_blockchain,
         'cd :path && RAILS_ENV=:environment :bundle_bin exec :ruby_bin script/blockchain/:task >> :whenever_path/log/:task.log 2>&1'
job_type :ruby_script_archives,
          'cd :path && RAILS_ENV=:environment :bundle_bin exec :ruby_bin script/archives/:task >> :whenever_path/log/:task.log 2>&1'

# Make sure you add the tasks to correct server.
# Use :background role to add task to background server (recommended),
# or :web role to add the task to web servers (www1, www2).

every 1.hour, at: 0, roles: [:background] do
  runner "AsnLogicWorker.perform_async('network' => 'mainnet')"
end

every 1.hour, at: 5, roles: [:background] do
  runner "AsnLogicWorker.perform_async('network' => 'testnet')"
  runner "AsnLogicWorker.perform_async('network' => 'pythnet')"
  ruby_script_data_centers "check_hetzner_admin_warning.rb"
end

every 1.hour, at: 10, roles: [:background] do
  ruby_script 'validators_get_info.rb'
  ruby_script 'validators_get_keybase_avatar_url.rb'
end

every 1.hour, at: 11, roles: [:background] do
  runner "PingThingFeeStatsWorker.perform_async()"
end

every 1.hour, at: 15, roles: [:background] do
  ruby_script 'gather_stake_accounts.rb'
end

every 1.hour, at: 30, roles: [:background] do
  ruby_script_data_centers 'append_data_centers_geo_data.rb'
end

every 1.hour, at: 35, roles: [:background] do
  ruby_script_data_centers 'assign_data_center_scores.rb'
end

every 1.hour, at: 40, roles: [:background] do
  ruby_script_data_centers 'fix_data_centers_hetzner.rb'
end

every 1.hour, at: 45, roles: [:background] do
  ruby_script_data_centers 'fix_data_centers_ovh.rb'
end

every 1.hour, at: 50, roles: [:background] do
  ruby_script_data_centers 'fix_data_centers_webnx.rb'
end

every 1.hour, at: 55, roles: [:web] do
  rake "-s sitemap:refresh"
end

every :sunday, at: '0:54am', roles: [:web] do
  rake "-s sitemap:clean"
end

every 1.day, at: '0:15am', roles: [:background] do
  ruby_script_sol_prices 'coin_gecko_gather_yesterday_prices.rb'
  ruby_script_data_centers 'append_to_unknown_data_center.rb'
end

every 1.day, at: '1:00am', roles: [:background] do
  ruby_script 'validators_update_keybase_avatar_url.rb'
end

every 1.day, at: '2:00am', roles: [:background] do
  ruby_script 'remove_unconfirmed_users.rb'
end

every 1.day, at: '2:20am', roles: [:background] do
  ruby_script 'update_gossip_nodes.rb'
end

every 1.day, at: '3:00am', roles: [:background] do
  runner "DataCenterStatsWorker.perform_async('mainnet')"
  runner "DataCenterStatsWorker.perform_async('testnet')"
  runner "DataCenterStatsWorker.perform_async('pythnet')"
end

every 1.day, at: '3:10am', roles: [:background] do
  ruby_script_data_centers 'check_unknown_data_centers_for_updates.rb'
end

every 1.day, at: '3:35am', roles: [:background] do
  ruby_script 'update_jito_validators.rb'
end

every 1.day, at: '3:40am', roles: [:background] do
  ruby_script 'update_validator_stake_pools_list.rb'
end

every 1.day, at: '5:00am', roles: [:background] do
  ruby_script_blockchain 'get_leaders_schedule.rb'
end

every 1.day, at: '5:10am', roles: [:background] do
  ruby_script_archives 'archive_ping_thing_stat.rb'
  ruby_script_archives 'archive_ping_thing.rb'
end

every 7.days, at: '4:00am', roles: [:background] do
  ruby_script 'validators_update_avatar_files.rb'
end

every 20.minutes, roles: [:background] do
  runner "ValidatorCheckActiveWorker.perform_async"
end

every 1.minute, roles: [:background] do
  ruby_script "add_current_epoch.rb"
  runner "PingThingStatsWorker.set(queue: :high_priority).perform_async"
  runner "PingThingRecentStatsWorker.perform_async('mainnet')"
  runner "PingThingRecentStatsWorker.perform_async('testnet')"
  runner "PingThingRecentStatsWorker.perform_async('pythnet')"
  runner "PingThingUserStatsWorker.perform_async('mainnet')"
  runner "PingThingUserStatsWorker.perform_async('testnet')"
  runner "PingThingUserStatsWorker.perform_async('pythnet')"
end

every 90.minutes, roles: [:background] do
  ruby_script_blockchain "check_error_slots.rb"
end

if environment == 'production'
  every 1.day, at: '1:00am', roles: [:background] do
    ruby_script 'prune_database_tables.rb'
  end
elsif environment == 'stage'
  every 1.day, at: '1:00pm', roles: [:background] do
    ruby_script 'prune_database_tables.rb'
  end
end

# Production only
if ENV['RAILS_ENV'] == "production"
  every 1.hour, at: 45, roles: [:background] do
    ruby_script 'gather_explorer_stake_accounts.rb'
  end
end
