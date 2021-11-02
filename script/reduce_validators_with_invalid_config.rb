# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/validators_get_avatar_url.rb
require File.expand_path('../config/environment', __dir__)

# Default URL is at 'https://keybase.io/images/no-photo/placeholder-avatar-180-x-180@2x.png'

include SolanaLogic

network = 'mainnet'

payload = {
  config_urls: Rails.application.credentials.solana[:mainnet_urls],
  network: network
}

begin
  puts 'Looking for config accounts...'
  p = Pipeline.new(200, payload)
              .then(&validators_info_get)
              .then(&program_accounts)
              .then(&find_invalid_configs)

  false_signers = p.payload[:false_signers]
  
  if false_signers.any?
    keys = false_signers.keys
    validators = Validator.where(info_pub_key: keys)

    validators.each do |val|
      val.update(
        name: nil,
        keybase_id: nil,
        www_url: nil,
        details: nil,
        info_pub_key: nil
      )
    end
  else
    puts 'No false signers, nothing to remove.'
  end
rescue StandardError => e
  puts "#{e.class}\n#{e.message}"
end # begin
