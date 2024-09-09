# frozen_string_literal: true

require_relative '../config/environment'

class SkipAndSleep < StandardError; end

begin
  loop do
    NETWORKS.each do |network|
      Gatherers::VoteAccountDetailsService.new(
        network: network,
        config_urls: NETWORK_URLS[network]
      ).call
    end
  rescue SkipAndSleep => e
    if e.message.in? %w[500 502 503 504]
      sleep(1.minute)
    else
      sleep(10.seconds)
    end
  rescue ActiveRecord::ConnectionNotEstablished => e
    Appsignal.send_error(e)
    break
  end
rescue StandardError => e
  puts "#{e.class}\n#{e.message}"
end
