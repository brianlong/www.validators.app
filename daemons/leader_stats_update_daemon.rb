# frozen_string_literal: true

require_relative "../config/environment"
require_relative "concerns/leader_stats_helper"

include LeaderStatsHelper

sleep_time = 2 # seconds

loop do
  begin
    leaders = all_leaders
    print leaders
    ActionCable.server.broadcast("leaders_channel", leaders)
    sleep(sleep_time)
  rescue => e
    puts e
    puts e.backtrace
    sleep(sleep_time)
    next
  end
end
