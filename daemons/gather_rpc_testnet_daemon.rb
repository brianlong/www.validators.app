# frozen_string_literal: true

require_relative '../config/environment'
require 'solana_logic'
include SolanaLogic

# Send an interrupt with `ctrl-c` or `kill` to stop the script. Results will
# not be posted to the validators.app server.
interrupted = false
trap('INT') { interrupted = true }  unless Rails.env.test?

class SkipAndSleep < StandardError; end

network = 'testnet'
sleep_time = 60 # seconds

begin
  loop do
    # Create our initial payload with the input values
    payload = {
      config_urls: Rails.application.credentials.solana[:testnet_urls],
      network: network
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
                .then(&check_epoch)

    raise SkipAndSleep, p.code unless p.code == 200

    BuildSkippedSlotPercentWorker.perform_async(
      network: p.payload[:network],
      batch_uuid: p.payload[:batch_uuid]
    )
    ReportTowerHeightWorker.perform_async(
      epoch: p.payload[:epoch],
      batch_uuid: p.payload[:batch_uuid],
      network: p.payload[:network]
    )
    ReportSoftwareVersionWorker.perform_async(
      batch_uuid: p.payload[:batch_uuid],
      network: p.payload[:network]
    )

    break if interrupted
  rescue SkipAndSleep => e
    break if interrupted

    if e.message.in? %w[500 502 503 504]
      sleep(2.minute)
    else
      sleep(sleep_time)
    end
  end
rescue StandardError => e
  puts "#{e.class}\n#{e.message}"
end # begin
