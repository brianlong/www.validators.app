# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)

begin_minutes_ago = 1440 # 24 hours
# begin_minutes_ago = 60 # 1 hour

begin_minutes_ago.times.each do |n|
  CreatePingThingStatsService.new(time_to: (begin_minutes_ago - n).minutes.ago, network: 'testnet').call
end