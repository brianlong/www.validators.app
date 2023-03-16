# frozen_string_literal: true

require_relative '../config/environment'

class SkipAndSleep < StandardError; end

# Send an interrupt with `ctrl-c` or `kill` to stop the script
interrupted = false
trap('INT') { interrupted = true }  unless Rails.env.test?

begin
  loop do
    if PingThingRaw.exists?
      ProcessPingThingsService.new(records_count: 100).call
    else
      sleep(3)
    end
    
    break if interrupted
  end
rescue => e
  puts e
end
