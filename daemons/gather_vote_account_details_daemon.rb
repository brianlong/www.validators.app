# frozen_string_literal: true

require_relative '../config/environment'

class SkipAndSleep < StandardError; end

begin
  loop do
    NETWORKS.each do |network|
      config_urls =
        case network
        when "mainnet" then Rails.application.credentials.solana[:mainnet_urls]
        when "testnet" then Rails.application.credentials.solana[:testnet_urls]
        when "pythnet" then Rails.application.credentials.solana[:pythnet_urls]
        end

      Gatherers::VoteAccountDetailsService.new(
        network: network,
        config_urls: config_urls
      ).call
    end
  rescue SkipAndSleep => e
    if e.message.in? %w[500 502 503 504]
      sleep(1.minute)
    else
      sleep(10.seconds)
    end
  end
rescue StandardError => e
  puts "#{e.class}\n#{e.message}"
end
