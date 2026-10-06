# frozen_string_literal: true

module Blockchain
  class AlpenglowEpochStatsService
    BATCH_SIZE = 5_000
    FINALITY_LAG = 32
    RANKS_WAIT_LIMIT = 30.minutes

    LOG_PATH = Rails.root.join("log", "#{name.demodulize.underscore}.log")

    def initialize(network:, epoch_schedule: nil)
      @network = network
      @footer_class = Blockchain::BlockFooter.network(network)
      @epoch_schedule = epoch_schedule
      @logger = Logger.new(LOG_PATH)
    end

    def call
      footers = pending_footers
      return 0 if footers.empty?

      certificates = AlpenglowEpochStats::CertificateIndex.new(footer_class: @footer_class, footers: footers).call
      footers, certificates = processable(footers, certificates)
      return 0 if footers.empty?

      leaders = AlpenglowEpochStats::LeaderCounter.new(footer_class: @footer_class).call(footers, certificates[:final])
      votes = AlpenglowEpochStats::VoteCounter.new(
        network: @network, footer_class: @footer_class, epoch_schedule: epoch_schedule
      ).call(certificates)

      ApplicationRecord.transaction do
        AlpenglowEpochStats::Writer.new(network: @network, logger: @logger).call(
          leader_counters: leaders.counters, voting_counters: votes.counters, user_agents: leaders.user_agents
        )
        @footer_class.where(id: footers.map(&:id)).update_all(processed: true, updated_at: Time.current)
      end

      @logger.info("Processed #{footers.size} footers up to slot #{footers.last.slot_number} on #{@network}")
      footers.size
    end

    private

    def epoch_schedule
      @epoch_schedule ||= Blockchain::EpochSchedule.fetch(@network)
    end

    def pending_footers
      max_slot = @footer_class.maximum(:slot_number)
      return [] if max_slot.nil?

      @footer_class.where(processed: false)
                   .where("slot_number <= ?", max_slot - FINALITY_LAG)
                   .order(:slot_number)
                   .limit(BATCH_SIZE)
                   .to_a
    end

    def processable(footers, certificates)
      blocking = first_footer_waiting_for_ranks(certificates)
      return [footers, certificates] if blocking.nil?

      if blocking.created_at < RANKS_WAIT_LIMIT.ago
        @logger.warn(
          "Ranks not finalized for slot #{blocking.slot_number} on #{@network} after #{RANKS_WAIT_LIMIT.inspect}, skipping votes"
        )
        return [footers, certificates]
      end

      @logger.info("Waiting for finalized ranks on #{@network}, stopping before slot #{blocking.slot_number}")
      before_blocking = ->(footer) { footer.slot_number < blocking.slot_number }
      kept_certificates = certificates.transform_values { |firsts| firsts.select { |_, footer| before_blocking.call(footer) } }
      [footers.select(&before_blocking), kept_certificates]
    end

    def first_footer_waiting_for_ranks(certificates)
      pending_epochs = provisional_only_epochs(certificates.values.flat_map(&:keys).map { |slot| epoch_schedule.epoch_for(slot) }.uniq)
      return nil if pending_epochs.empty?

      certificates.values.flat_map do |firsts|
        firsts.filter_map { |slot, footer| footer if pending_epochs.include?(epoch_schedule.epoch_for(slot)) }
      end.min_by(&:slot_number)
    end

    def provisional_only_epochs(epochs)
      counts = AlpenglowEpochRank.where(network: @network, epoch: epochs).group(:epoch, :finalized).count
      epochs.select { |epoch| counts[[epoch, true]].to_i.zero? && counts[[epoch, false]].to_i.positive? }.to_set
    end
  end
end
