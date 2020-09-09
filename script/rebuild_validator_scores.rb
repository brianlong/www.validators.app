# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/rebuild_validator_scores.rb
require File.expand_path('../config/environment', __dir__)

verbose = true

Validator.find_each do |validator|
  validator.validator_score_v1.skipped_slot_history = validator.validator_block_histories.order('id desc').limit(2_880).map(&:skipped_slot_percent).reverse
  validator.validator_score_v1.save
end
