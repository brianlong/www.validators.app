# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)

raise "Dev script can't be executed on production" if Rails.env.production?

include AsnLogic

network = ARGV[0] || 'mainnet'

payload = {
  network: network
}

p = Pipeline.new(200, payload)
            .then(&gather_asns)
            .then(&gather_scores)
            .then(&prepare_asn_stats)
            .then(&calculate_and_save_stats)
            .then(&log_errors_to_file)

# puts p.payload[:asn_stats].inspect

if p.errors
  puts p.errors.message
  puts p.errors.backtrace
end
