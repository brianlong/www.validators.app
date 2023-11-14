# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/validators_get_avatar_url.rb
require File.expand_path('../config/environment', __dir__)

include KeybaseLogic

interrupted = false
trap('INT') { interrupted = true }  unless Rails.env.test?

NETWORKS.each do |network|
  Validator.where(network: network).where.not(keybase_id: '').where.not(avatar_url: nil).find_each do |validator|
    validator_url = get_validator_avatar(validator.keybase_id)
    if(validator_url != validator.avatar_url)
      validator.update(avatar_url: validator_url)
    end
    sleep(1)
  end
end
