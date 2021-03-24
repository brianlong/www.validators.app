# frozen_string_literal: true

# NOTE:
# There are currently these tasks running in production. Remove these once
# schedule.rb is working correctly.
#
# 0,5,10,15,20,25,30,35,40,45,50,55 * * * * /bin/bash -l -c 'cd /home/deploy/validators.app/current && RAILS_ENV=production /usr/bin/bundle exec /usr/bin/ruby script/gather_rpc_data.rb >> /home/deploy/validators.app/current/log/gather_rpc_data.rb.log 2>&1'

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
job_type :ruby_script, 'cd :path && RAILS_ENV=:environment :bundle_bin exec :ruby_bin script/:task >> :whenever_path/log/:task.log 2>&1'

every 2.minutes do
  ruby_script 'gather_rpc_data_mainnet.rb'
end

every 6.minutes do
 ruby_script 'gather_rpc_data.rb'
end

every 1.hour do
  ruby_script 'validators_get_info.rb'
  ruby_script 'validators_get_avatar_url.rb'
  ruby_script 'append_ip_geo_data.rb'
  ruby_script 'assign_data_center_scores.rb'
  ruby_script 'fix_ip_hetzner.rb'
  ruby_script 'fix_ip_ovh.rb'
end

every 1.day do
  ruby_script 'prune_database_tables.rb'
end
