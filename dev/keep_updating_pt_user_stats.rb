#frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)

raise "Dev script can't be executed on production" if Rails.env.production?

interrupted = false
trap('INT') { interrupted = true }  unless Rails.env.test?

loop do
  PingThingUserStatsService.new(network: "mainnet", interval: 60).call
  PingThingUserStatsService.new(network: "mainnet", interval: 5).call
  puts "there are #{PingThingUserStat.count} ping thing user stats"
  break if interrupted
  sleep(30)
end
