# frozen_string_literal: true

require_relative '../config/environment'
require 'solana_logic'
include SolanaLogic

# Send an interrupt with `ctrl-c` or `kill` to stop the script. Results will
# not be posted to the validators.app server.
interrupted = false
trap('INT') { interrupted = true } unless Rails.env.test?

class SkipAndSleep < StandardError; end

network = 'alpenglow-community'
sleep_time = Rails.env.stage? ? 180 : 60 # seconds

begin
  loop do
    payload = {
      config_urls: Rails.application.credentials.solana[:alpenglow_community_urls],
      network: network
    }

    # program_accounts (getProgramAccounts) is unavailable on Alpenglow (returns 503),
    # so skip it along with find_invalid_configs and remove_invalid_configs.
    p = Pipeline.new(200, payload)
                .then(&batch_set)
                .then(&epoch_get)
                .then(&validators_get)
                .then(&vote_accounts_get)
                .then(&reduce_validator_vote_accounts)
                .then(&validators_save)
                .then(&validator_history_update)
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

    sleep(sleep_time) if Rails.env.stage?
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
end
