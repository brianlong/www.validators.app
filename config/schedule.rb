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

# since only one server should be responsible for background scripts and daemons
# role background should be set on every schedule to limit it to a correct server

every 1.hour, at: 0, roles: [:background] do
  runner "AsnLogicWorker.perform_async(network: 'mainnet')"
  runner "AsnLogicWorker.perform_async(network: 'testnet')"
  runner "AsnLogicWorker.perform_async(network: 'pythnet')"
  ruby_script_data_centers "check_hetzner_admin_warning.rb"
end

every 1.hour, at: 5, roles: [:background] do
  ruby_script 'validators_get_info.rb'
  ruby_script 'validators_get_avatar_url.rb'
end

every 2.hour, at: 10, roles: [:background] do
  ruby_script 'gather_stake_accounts.rb'
end

every 1.hour, at: 20, roles: [:background] do
  ruby_script_data_centers 'append_data_centers_geo_data.rb'
end

every 1.hour, at: 25, roles: [:background] do
  ruby_script_data_centers 'assign_data_center_scores.rb'
end

every 1.hour, at: 30, roles: [:background] do
  ruby_script_data_centers 'fix_data_centers_hetzner.rb'
end

every 1.hour, at: 40, roles: [:background] do
  ruby_script_data_centers 'fix_data_centers_ovh.rb'
end

every 1.hour, at: 50, roles: [:background] do
  ruby_script_data_centers 'fix_data_centers_webnx.rb'
end

every 1.day, at: '0:15am', roles: [:background] do
  ruby_script_sol_prices 'coin_gecko_gather_yesterday_prices.rb'
  ruby_script_data_centers 'append_to_unknown_data_center.rb'
end

every 1.day, at: '1:00am', roles: [:background] do
  ruby_script 'validators_update_avatar_url.rb'
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

every 10.minutes, roles: [:background] do
  runner "ValidatorCheckActiveWorker.perform_async"
end

every 1.minute, roles: [:background] do
  ruby_script "add_current_epoch.rb"
  runner "PingThingStatsWorker.perform_async"
  runner "PingThingRecentStatsWorker.perform_async('mainnet')"
  runner "PingThingRecentStatsWorker.perform_async('testnet')"
  runner "PingThingRecentStatsWorker.perform_async('pythnet')"
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
