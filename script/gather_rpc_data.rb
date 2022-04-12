# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/gather_rpc_data.rb
require File.expand_path('../config/environment', __dir__)
require 'solana_logic'

include SolanaLogic

# Create our initial payload with the input values
payload = {
  config_urls: Rails.application.credentials.solana[:testnet_urls],
  network: 'testnet'
}

p = Pipeline.new(200, payload)
            .then(&batch_set)
            .then(&epoch_get)
            .then(&validators_cli)
            .then(&validators_get)
            .then(&vote_accounts_get)
            .then(&reduce_validator_vote_accounts)
            .then(&validators_save)
            .then(&validator_block_history_get)
            .then(&validator_block_history_save)
            .then(&log_errors)
            .then(&batch_touch)

# puts p.payload[:batch_uuid]
# puts p.code
# puts p.errors

if p.code == 200
  common_params = {
    batch_uuid: p.payload[:batch_uuid],
    network: p.payload[:network]
  }.stringify_keys

  BuildSkippedSlotPercentWorker.perform_async(common_params)
  ReportTowerHeightWorker.perform_async(common_params.merge({ epoch: p.payload[:epoch] }).stringify_keys)
  ReportSoftwareVersionWorker.perform_async(common_params)

  # ValidatorScoreV1Worker.perform_async(
  #   network: p.payload[:network],
  #   batch_uuid: p.payload[:batch_uuid]
  # )

  # include ValidatorScoreV1Logic
  # include PipelineLogic
  #
  # score_payload = {
  #   network: p.payload[:network],
  #   batch_uuid: p.payload[:batch_uuid]
  # }
  #
  # score = Pipeline.new(200, score_payload)
  #                 .then(&set_this_batch)
  #                 .then(&validators_get)
  #                 .then(&block_vote_history_get)
  #                 .then(&assign_block_and_vote_scores)
  #                 .then(&block_history_get)
  #                 .then(&assign_block_history_score)
  #                 .then(&assign_software_version_score)
  #                 .then(&get_ping_times)
  #                 .then(&save_validators)
  #                 .then(&log_errors)
  #
  # puts score.code
  # puts score.message
  # if score.errors
  #   puts score.errors.message
  #   puts score.errors.backtrace
  # end
end
