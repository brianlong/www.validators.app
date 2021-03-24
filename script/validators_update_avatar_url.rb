# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/validators_get_avatar_url.rb
require File.expand_path('../config/environment', __dir__)
# Default URL is at 'https://keybase.io/images/no-photo/placeholder-avatar-180-x-180@2x.png'

include KeybaseLogic

interrupted = false
trap('INT') { interrupted = true }

%w[testnet mainnet].each do |network|
  Validator.where(network: network).where.not(keybase_id: '').where.not(avatar_url: nil).each do |validator|
    if validator.avatar_url == DEFAULT_AVATAR_URL || ['404', '403'].include?(Net::HTTP.get_response(URI(validator.avatar_url)).code)
      validator_url = get_validator_avatar(validator.keybase_id)
      validator.update(avatar_url: validator_url)
      sleep(1)
    end
  end
end