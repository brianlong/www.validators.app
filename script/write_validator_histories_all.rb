# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/write_validator_histories.rb

require File.expand_path('../config/environment', __dir__)
require 'csv'

CSV.open('/tmp/validator_histories_all.csv', 'w') do |csv|
  csv << %w[id network batch_uuid account vote_account commission last_vote root_block credits active_stake delinquent software_version epoch_credits slot_skip_rate max_root_height root_distance max_vote_height vote_distance epoch created_at updated_at]
  ValidatorHistory.where(
    "network = 'mainnet'"
  ).find_each do |vh|
    csv << [
      vh.id,
      vh.network,
      vh.batch_uuid,
      vh.account,
      vh.vote_account,
      vh.commission,
      vh.last_vote,
      vh.root_block,
      vh.credits,
      vh.active_stake,
      vh.delinquent,
      vh.software_version,
      vh.epoch_credits,
      vh.slot_skip_rate,
      vh.max_root_height,
      vh.root_distance,
      vh.max_vote_height,
      vh.vote_distance,
      vh.epoch,
      vh.created_at,
      vh.updated_at
    ]
  end
end
