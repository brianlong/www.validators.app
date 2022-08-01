# frozen_string_literal: true

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
  config_urls = if network == 'testnet'
    Rails.application.credentials.solana[:testnet_urls]
  else
    Rails.application.credentials.solana[:mainnet_urls]
  end

  Gatherers::VoteAccountDetailsService.new(
    network: network,
    config_urls: config_urls,
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
