# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/validators_get_info.rb
require File.expand_path('../config/environment', __dir__)
require 'solana_logic'

include SolanaLogic

# {
#   "identityPubkey": "71bhKKL89U3dNHzuZVZ7KarqV6XtHEgjXjvJTsguD11B",
#   "infoPubkey": "FRZR9KVav9brvchLUjBZm6Y4Ur9Nv4T1ckGY4fqk7y2z",
#   "info": {
#     "keybaseUsername": "brianlong",
#     "name": "BL",
#     "website": "https://www.fmadata.com"
#   }
# }
# mainnet

%w[testnet mainnet].each do |network|
  puts network
  payload = {
    config_urls: Rails.application.credentials.solana["#{network}_urls".to_sym],
    network: network
  }

  p = Pipeline.new(200, payload)
              .then(&validator_info_get_and_save)
              .then(&log_errors)
              .then(&batch_touch)

  # puts p.inspect
end
