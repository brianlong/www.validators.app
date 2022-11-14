# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)

include SolanaLogic

NETWORKS.each do |network|
  payload = {
    config_urls: Rails.application.credentials.solana["#{network}_urls".to_sym],
    network: network
  }

  begin
    puts "Looking for config accounts for #{network}..."
    p = Pipeline.new(200, payload)
                .then(&validators_info_get)
                .then(&program_accounts)
                .then(&find_invalid_configs)

    false_signers = p.payload[:false_signers]
    
    if false_signers.any?
      keys = false_signers.keys
      validators = Validator.where(info_pub_key: keys)

      puts "Validators ids to update: #{validators.ids}"

      validators.update_all(
          name: nil,
          keybase_id: nil,
          www_url: nil,
          details: nil,
          info_pub_key: nil
        )
    else
      puts 'No false signers, nothing to update.'
    end
  rescue StandardError => e
    puts "#{e.class}\n#{e.message}\n#{e.backtrace}"
  end # begin
end
