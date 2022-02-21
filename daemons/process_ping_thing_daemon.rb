# frozen_string_literal: true

require_relative '../config/environment'

class SkipAndSleep < StandardError; end

# Send an interrupt with `ctrl-c` or `kill` to stop the script
interrupted = false
trap('INT') { interrupted = true }  unless Rails.env.test?

begin
  loop do
    ProcessPingThingsService.new(records_count: 100).call
    break if ARGV[0] == "once" || interrupted
    sleep(5)
  end
rescue => e
  puts e
end
