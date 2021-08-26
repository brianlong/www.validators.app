# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/gather_vote_account_details.rb
require File.expand_path('../config/environment', __dir__)
include SolanaLogic

begin
  loop do
    %w[mainnet testnet].each do |network|

      config_urls = if network == 'testnet'
        Rails.application.credentials.solana[:testnet_urls]
      else
        Rails.application.credentials.solana[:mainnet_urls]
      end
      VoteAccount.where(network: network).each do |vacc|
        vote_account_details = cli_request(
          "vote-account #{vacc.account}",
          config_urls
        )

        vacc.update(
          validator_identity: vote_account_details["validatorIdentity"],
          authorized_withdrawer: vote_account_details["authorizedWithdrawer"]
        )

        # -2 points if withdrawer and id are the same
        if vacc && vacc.validator_identity == vacc.authorized_withdrawer
          vacc.validator.validator_score_v1.authorized_withdrawer_score = -2
        else
          vacc.validator.validator_score_v1.authorized_withdrawer_score = 0
        end
      end
      puts "#{network} done"
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
