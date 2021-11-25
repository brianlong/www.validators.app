# frozen_string_literal: true

require_relative '../config/environment'

class SkipAndSleep < StandardError; end

begin
  loop do
    %w[mainnet testnet].each do |network|
      config_urls = if network == 'testnet'
        Rails.application.credentials.solana[:testnet_urls]
      else
        Rails.application.credentials.solana[:mainnet_urls]
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
