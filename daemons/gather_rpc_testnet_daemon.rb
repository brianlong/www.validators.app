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
                .then(&validators_get)
                .then(&program_accounts)
                .then(&vote_accounts_get)
                .then(&reduce_validator_vote_accounts)
                .then(&validators_save)
                .then(&validators_cli)
                .then(&validator_block_history_get)
                .then(&validator_block_history_save)
                .then(&log_errors)
                .then(&batch_touch)
                .then(&check_epoch)

    raise SkipAndSleep, p.code unless p.code == 200

    common_params = {
      batch_uuid: p.payload[:batch_uuid],
      network: p.payload[:network]
    }.stringify_keys

    BuildSkippedSlotPercentWorker.perform_async(common_params)
    ReportSoftwareVersionWorker.perform_async(common_params)

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
