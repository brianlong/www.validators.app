# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/validators_get_avatar_url.rb
# This script refreshes existing keybase avatars, doesn't override non-keybase avatars

require File.expand_path('../config/environment', __dir__)

include KeybaseLogic

interrupted = false
trap('INT') { interrupted = true }  unless Rails.env.test?

keybase_url_pattern = /^https:\/\/s3.amazonaws.com\/keybase_processed_uploads/

NETWORKS.each do |network|
  Validator.active.where(network: network)
           .where.not(keybase_id: '')
           .where.not(avatar_url: nil)
           .find_each do |validator|
    next unless validator.avatar_url.match? keybase_url_pattern
    new_validator_url = get_validator_avatar(validator.keybase_id)
    if(new_validator_url != validator.avatar_url)
      validator.update(avatar_url: new_validator_url)
    end
    sleep(1)
  end
end
