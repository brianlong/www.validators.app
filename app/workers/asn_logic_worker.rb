# frozen_string_literal: true

class AsnLogicWorker
  include Sidekiq::Worker
  include AsnLogic

  def perform(args = {})
    payload = {
      network: args['network']
    }

    Pipeline.new(200, payload)
            .then(&gather_asns)
            .then(&gather_scores)
            .then(&prepare_asn_stats)
            .then(&calculate_and_save_stats)
            .then(&log_errors_to_file)

  end
end
