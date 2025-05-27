#frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)

raise "Dev script can't be executed on production" if Rails.env.production?

interrupted = false
trap('INT') { interrupted = true }  unless Rails.env.test?

loop do
  PingThingRecentStatsWorker.perform_async("mainnet")
  PingThingUserStatsWorker.perform_async("mainnet")
  break if interrupted
  sleep(60)
end
