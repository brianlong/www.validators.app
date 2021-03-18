# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/validators_get_avatar_url.rb
require File.expand_path('../config/environment', __dir__)
require File.expand_path('./app/services/keybase_service.rb')
# Default URL is at 'https://keybase.io/images/no-photo/placeholder-avatar-180-x-180@2x.png'

# include AgentLogic
# include KeyBaseService

interrupted = false
trap('INT') { interrupted = true }

agent = Mechanize.new
keybase_service = KeyBaseService.new

%w[testnet mainnet].each do |network|
  Validator.where(
    ["network = ? and keybase_id != '' AND avatar_url IS NOT NULL", network]
  ).each do |validator|
    begin
      validator_avatar = agent.get(validator.avatar_url)
    rescue StandardError => e
      if e.response_code && ['404', '403'].include?(e.response_code)
        keybase_service.get_validator_avatar(validator)
      end
    end
  end
end