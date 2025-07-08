# frozen_string_literal: true

require_relative '../config/environment'
require 'solana_logic'
include SolanaLogic

# Send an interrupt with `ctrl-c` or `kill` to stop the script. Results will
# not be posted to the validators.app server.
interrupted = false
trap('INT') { interrupted = true }  unless Rails.env.test?

class SkipAndSleep < StandardError; end

network = 'mainnet'
sleep_time = Rails.env.stage? ? 90 : 15 # seconds

begin
  loop do
    # Create our initial payload with the input values
    payload = {
      config_urls: Rails.application.credentials.solana[:mainnet_urls],
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
                .then(&validator_history_update)
                .then(&validator_block_history_get)
                .then(&validator_block_history_save)
                .then(&log_errors)
                .then(&batch_touch)
                .then(&check_epoch)

    # After switching to better server we exceed connection rate limit:
    # Maximum connection rate per 10 seconds per IP: 40
    # We want to slow down a bit.
    #
    # More info about limits:
    # https://docs.solana.com/cluster/rpc-endpoints#mainnet-beta
    sleep 2

    raise SkipAndSleep, p.code unless p.code == 200

    common_params = {
      batch_uuid: p.payload[:batch_uuid],
      network: p.payload[:network]
    }.stringify_keys

    BuildSkippedSlotPercentWorker.set(queue: :high_priority).perform_async(common_params)
    ReportSoftwareVersionWorker.set(queue: :high_priority).perform_async(common_params)

    break if interrupted

    sleep(sleep_time) if Rails.env.stage?
  rescue SkipAndSleep => e
    break if interrupted

    if e.message.in? %w[500 502 503 504]
      sleep(1.minute)
    else
      sleep(sleep_time)
    end
  end
rescue StandardError => e
  puts "#{e.class}\n#{e.message}"
end # begin
