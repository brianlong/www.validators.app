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

set :output, "#{Rails.root}/log/schedule.log"

job_type :ruby_script, 'cd :path && RAILS_ENV=:environment :bundle_bin exec :ruby_bin script/:task >> #{Rails.root}/:task.log 2>&1'

every 5.minutes do
  ruby_script 'gather_rpc_data.rb'
end
