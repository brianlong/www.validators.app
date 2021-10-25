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
              .then(&program_accounts)

  program_accounts = p.payload[:program_accounts]
  info_pubkey = 'Va1idator1nfo111111111111111111111111111111'

  data = p.payload[:program_accounts].map { |e| e.dig('account', 'data') }

  keys = data.map do |e|
    next if e.is_a?(Array)
    e.dig('parsed', 'info', 'keys')
  end.flatten.compact

  pubkeys_signers = keys.reject { |e| e['pubkey'] == info_pubkey }
  false_signers = pubkeys_signers.select { |e| e['signer'] == false }

  if false_signers.any?
    false_signers.each do |signer|
      puts "Signer false for pubkey: #{signer['pubkey']}"
      validator = Validator.find_by(account: signer['pubkey'])
      validator.destroy
      puts "Validator #{validator} has been removed."
    end
  else
    puts 'No false signers, nothing to remove.'
  end
rescue StandardError => e
  puts "#{e.class}\n#{e.message}"
end # begin
