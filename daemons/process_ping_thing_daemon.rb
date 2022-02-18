# frozen_string_literal: true

require_relative '../config/environment'

class SkipAndSleep < StandardError; end

begin
  loop do
    ProcessPingThingsService.new(records_count: 100).call
    sleep(5)
  end
rescue => e
  puts e
end