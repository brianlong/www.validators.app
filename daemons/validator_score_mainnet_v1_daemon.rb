# frozen_string_literal: true

require_relative '../config/environment'
include ValidatorScoreV1Logic
include PipelineLogic

# Send an interrupt with `ctrl-c` or `kill` to stop the script. Results will
# not be posted to the validators.app server.
interrupted = false
trap('INT') { interrupted = true }  unless Rails.env.test?

network = 'mainnet'
sleep_time = Rails.env.stage? ? 30 : 15 # seconds

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
                 .then(&block_vote_history_get)
                 .then(&assign_block_and_vote_scores)
                 .then(&block_history_get)
                 .then(&assign_block_history_score)
                 .then(&assign_software_version_score)
                 .then(&save_validators)
                 .then(&log_errors)

    # Mark the batch as scored
    batch.scored_at = Time.now
    batch.save

    stat_params = {
      batch_uuid: batch.uuid,
      network: _p.payload[:network]
    }.stringify_keys

    ClusterStatsWorker.set(queue: :high_priority).perform_async(stat_params)
    #TODO change to stage
    # Blockchain::VoteLatencyScoreWorker.set(queue: "blockchain_#{_p.payload[:network]}").perform_async({"network" => _p.payload[:network]}) unless Rails.env.production?

    break if interrupted
  rescue SkipAndSleep
    break if interrupted
    sleep(sleep_time)
  end
rescue StandardError => e
  puts "#{e.class}\n#{e.message}"
end # begin
