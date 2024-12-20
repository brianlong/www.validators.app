# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)

raise "Dev script can't be executed on production" if Rails.env.production?

puts "stopping gather_vote_account_details.service"
begin
  `systemctl --user stop gather_vote_account_details.service`
  puts "done"
rescue Errno::ENOENT
  puts "process not found"
end

%w[mainnet testnet].each do |network|
  puts "getting #{network} validators"
  puts "----------------------------"

  Gatherers::VoteAccountDetailsService.new(
    network: network,
    config_urls: NETWORK_URLS[network],
    always_update: true
  ).call
end

puts "starting gather_vote_account_details.service"
begin
  `systemctl --user start gather_vote_account_details.service`
  puts "done"
rescue Errno::ENOENT
  puts "process not found"
end
