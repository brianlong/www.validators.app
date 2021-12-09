# frozen_string_literal: true

require_relative "../config/environment"
include ValidatorScoreV2Logic
include PipelineLogic

# Send an interrupt with `ctrl-c` or `kill` to stop the script. Results will
# not be posted to the validators.app server.
interrupted = false
trap("INT") { interrupted = true } unless Rails.env.test?

network = "testnet"
sleep_time = 15 # seconds

class SkipAndSleep < StandardError; end

begin
  loop do
    # Select the most recently gathered batch
    batch = Batch.where(["network = ? AND gathered_at IS NOT NULL", network])
                 .last

    # Skip & sleep a few seconds if this batch was already scored.
    # We are waiting for the next batch
    raise SkipAndSleep if batch.nil?
    raise SkipAndSleep unless batch.scored_at.nil?

    payload = {
      network: network,
      batch_uuid: batch.uuid
    }

    _p = Pipeline.new(200, payload)
                 .then(&set_this_batch)
                 .then(&validators_get)
                 .then(&set_validators_groups)
                 .then(&assign_root_distance_scores)
                 .then(&assign_vote_distance_scores)
                 .then(&assign_skipped_slot_score)
                 .then(&save_validators)
                 .then(&log_errors)

    # Mark the batch as scored
    batch.scored_at = Time.now
    batch.save

    break if interrupted
  rescue SkipAndSleep
    break if interrupted
    sleep(sleep_time)
  end
rescue StandardError => e
  puts "#{e.class}\n#{e.message}"
end # begin
