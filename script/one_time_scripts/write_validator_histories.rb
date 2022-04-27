# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/write_validator_histories.rb

require File.expand_path('../config/environment', __dir__)
require 'csv'

account = '8yjHdsCgx3bp2zEwGiWSMgwpFaCSzfYAHT1vk7KJBqhN'

CSV.open('/tmp/validator_histories_all.csv', 'w') do |csv|
  csv << %w[id network batch_uuid account vote_account commission created_at updated_at]
  ValidatorHistory.where(
    ["network = 'mainnet' and account = ?", account]
  ).find_each do |vh|
    csv << [
      vh.id,
      vh.network,
      vh.batch_uuid,
      vh.account,
      vh.vote_account,
      vh.commission,
      vh.created_at,
      vh.updated_at
    ]
  end
end
