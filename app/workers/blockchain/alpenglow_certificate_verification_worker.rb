# frozen_string_literal: true

module Blockchain
  class AlpenglowCertificateVerificationWorker
    include Sidekiq::Worker
    sidekiq_options retry: 0, dead: false, queue: :default

    class VerificationFailed < StandardError; end

    LOG_PATH = Rails.root.join("log", "alpenglow_certificate_verification.log")
    FINALIZATION_TYPES = %w[fast slow_finalize slow_notarize].freeze

    def perform(network, certificates)
      verifier = Blockchain::AlpenglowCertificateVerifier.new(
        network: network,
        epoch_schedule: Blockchain::EpochSchedule.fetch(network),
        shred_version: Blockchain::AlpenglowCertificateVerifier.shred_version(network)
      )
      results = verifier.call(certificates)
      return if results.empty?

      invalid = results.reject { |result| result[:valid] }
      checked = results.map { |result| result.slice(:type, :slot) }
      logger.info("#{network}: #{results.size - invalid.size}/#{results.size} certificates valid #{checked}")
      results.group_by { |result| result[:epoch] }.each { |epoch, epoch_results| update_ranks(network, epoch, epoch_results) }
      return if invalid.empty?

      message = "Alpenglow certificate verification failed on #{network}: #{invalid}"
      logger.error(message)
      Appsignal.send_error(VerificationFailed.new(message))
    end

    private

    def update_ranks(network, epoch, results)
      if results.all? { |result| result[:valid] }
        return unless results.any? { |result| FINALIZATION_TYPES.include?(result[:type]) }

        AlpenglowEpochRank.mark_verified(network, epoch)
      else
        ApplicationRecord.transaction do
          AlpenglowEpochRank.mark_rejected(network, epoch)
          AlpenglowValidatorEpochStat.reset_voting(network, epoch)
        end
        logger.error("#{network}: ranks for epoch #{epoch} rejected, voting stats reset")
      end
    end

    def logger
      @logger ||= Logger.new(LOG_PATH)
    end
  end
end
