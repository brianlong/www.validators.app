interrupted = false
trap('INT') { interrupted = true }  unless Rails.env.test?

loop do
  PingThingUserStatsService.new(network: "mainnet", interval: 60).call
  PingThingUserStatsService.new(network: "mainnet", interval: 5).call
  puts "there are #{PingThingUserStat.count} ping thing user stats"
  break if interrupted
  sleep(30)
end
