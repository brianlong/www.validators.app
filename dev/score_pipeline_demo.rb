# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)
require 'validator_score_v1_logic'

include ValidatorScoreV1Logic

network = 'testnet'

batch = Batch.where(["network = ? AND gathered_at IS NOT NULL", network])
                 .last

payload = {
  network: network,
  batch_uuid: batch.uuid
}

p = Pipeline.new(200, payload)
             .then(&set_this_batch)
             .then(&validators_get)
             .then(&block_vote_history_get)
             .then(&assign_block_and_vote_scores)
             .then(&block_history_get)
             .then(&assign_block_history_score)
             .then(&assign_software_version_score)
             .then(&save_validators)
             .then(&log_errors)

puts "CODE: #{p[:code]}"
puts "MESSAGE: #{p[:message]}"
puts "ERROR: #{p[:errors].inspect}"