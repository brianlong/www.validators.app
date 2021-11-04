# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/validators_get_info.rb
require File.expand_path('../config/environment', __dir__)
require 'solana_logic'

include SolanaLogic

%w[mainnet testnet].each do |network|
  payload = {
    config_urls: Rails.application.credentials.solana["#{network}_urls".to_sym],
    network: network
  }

  _p = Pipeline.new(200, payload)
               .then(&validators_info_get)
               .then(&program_accounts)
               .then(&find_invalid_configs)
               .then(&remove_invalid_configs)
               .then(&validators_info_save)               
               .then(&log_errors)
               .then(&batch_touch)
end
