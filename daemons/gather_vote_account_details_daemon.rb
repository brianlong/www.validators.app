# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/gather_vote_account_details.rb
require File.expand_path('../config/environment', __dir__)

begin
  loop do
    %w[mainnet testnet].each do |network|
      config_urls = if @network == 'testnet'
        Rails.application.credentials.solana[:testnet_urls]
      else
        Rails.application.credentials.solana[:mainnet_urls]
      end

      Gatherers::GatherVoteAccountDetailsService.new(
        network: network,
        config_urls: config_urls
      ).call
    end
  rescue SkipAndSleep => e
    break if interrupted

    if e.message.in? %w[500 502 503 504]
      sleep(1.minute)
    else
      sleep(sleep_time)
    end
  end
rescue StandardError => e
  puts "#{e.class}\n#{e.message}"
end
