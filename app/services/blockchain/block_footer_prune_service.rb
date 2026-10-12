# frozen_string_literal: true

module Blockchain
  class BlockFooterPruneService
    RETENTION = 7.days
    BATCH_SIZE = 10_000

    LOG_PATH = Rails.root.join("log", "#{name.demodulize.underscore}.log")

    def initialize(network:, retention: RETENTION)
      @network = network
      @retention = retention
      @footer_class = Blockchain::BlockFooter.network(network)
      @logger = Logger.new(LOG_PATH)
    end

    def call
      cutoff = @retention.ago
      deleted = 0

      loop do
        ids = @footer_class.where("created_at < ?", cutoff).where(processed: true).limit(BATCH_SIZE).pluck(:id)
        break if ids.empty?

        deleted += @footer_class.where(id: ids).delete_all
      end

      @logger.info("Deleted #{deleted} #{@network} footers created before #{cutoff}")
      deleted
    end
  end
end
