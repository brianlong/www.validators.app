# frozen_string_literal: true

module Blockchain
  class AlpenglowLeaderStatsService
    BATCH_SIZE = 5_000
    FINALITY_LAG = 32
    DEDUP_WINDOW = 64

    COUNTERS = %i[
      leader_slots
      leader_slots_with_final_cert
      leader_fast_finalized
      leader_slow_finalized
      leader_final_lag_sum
    ].freeze

    LOG_PATH = Rails.root.join("log", "#{name.demodulize.underscore}.log")

    def initialize(network:)
      @network = network
      @footer_class = Blockchain::BlockFooter.network(network)
      @logger = Logger.new(LOG_PATH)
    end

    def call
      footers = pending_footers
      return 0 if footers.empty?

      counters = Hash.new { |hash, key| hash[key] = Hash.new(0) }
      user_agents = {}

      count_produced_blocks(footers, counters, user_agents)
      count_finalizations(footers, counters)

      ApplicationRecord.transaction do
        save_counters(counters, user_agents)
        @footer_class.where(id: footers.map(&:id)).update_all(processed: true, updated_at: Time.current)
      end

      @logger.info("Processed #{footers.size} footers up to slot #{footers.last.slot_number} on #{@network}")
      footers.size
    end

    private

    def pending_footers
      max_slot = @footer_class.maximum(:slot_number)
      return [] if max_slot.nil?

      @footer_class.where(processed: false)
                   .where("slot_number <= ?", max_slot - FINALITY_LAG)
                   .order(:slot_number)
                   .limit(BATCH_SIZE)
                   .to_a
    end

    def count_produced_blocks(footers, counters, user_agents)
      footers.each do |footer|
        next if footer.leader.blank?

        key = [footer.epoch, footer.leader]
        counters[key][:leader_slots] += 1
        counters[key][:leader_slots_with_final_cert] += 1 if footer.final_cert_slot
        user_agents[key] = footer.block_user_agent if footer.block_user_agent.present?
      end
    end

    def count_finalizations(footers, counters)
      first_certs = first_certificates(footers)
      finalized_blocks = @footer_class.where(slot_number: first_certs.keys).pluck(:slot_number, :epoch, :leader)

      finalized_blocks.each do |slot, epoch, leader|
        next if leader.blank?

        footer = first_certs[slot]
        key = [epoch, leader]
        counters[key][footer.fast? ? :leader_fast_finalized : :leader_slow_finalized] += 1
        counters[key][:leader_final_lag_sum] += footer.slot_number - slot
      end
    end

    def first_certificates(footers)
      already_seen = @footer_class.where(slot_number: (footers.first.slot_number - DEDUP_WINDOW)...footers.first.slot_number)
                                  .where.not(final_cert_slot: nil)
                                  .distinct
                                  .pluck(:final_cert_slot)
                                  .to_set

      footers.each_with_object({}) do |footer, certs|
        slot = footer.final_cert_slot
        next if slot.nil? || already_seen.include?(slot) || certs.key?(slot)

        certs[slot] = footer
      end
    end

    def save_counters(counters, user_agents)
      validators = Validator.where(network: @network, account: counters.keys.map(&:last).uniq)
                            .includes(:vote_accounts)
                            .index_by(&:account)
      now = Time.current

      rows = counters.filter_map do |(epoch, leader), values|
        validator = validators[leader]
        vote_account = validator&.vote_account_active
        if vote_account.nil?
          @logger.warn("Skipping leader #{leader} on #{@network}: validator or vote account not found")
          next
        end

        COUNTERS.to_h { |counter| [counter, values[counter]] }.merge(
          network: @network,
          epoch: epoch,
          vote_account_id: vote_account.id,
          validator_id: validator.id,
          last_block_user_agent: user_agents[[epoch, leader]],
          created_at: now,
          updated_at: now
        )
      end

      upsert_with_increment(rows) if rows.any?
    end

    def upsert_with_increment(rows)
      table = AlpenglowValidatorEpochStat.table_name
      columns = rows.first.keys
      values = rows.map do |row|
        "(#{columns.map { |column| ApplicationRecord.connection.quote(row[column]) }.join(', ')})"
      end
      updates = COUNTERS.map { |counter| "#{table}.#{counter} = #{table}.#{counter} + new_values.#{counter}" }
      updates << "#{table}.last_block_user_agent = COALESCE(new_values.last_block_user_agent, #{table}.last_block_user_agent)"
      updates << "#{table}.updated_at = new_values.updated_at"

      ApplicationRecord.connection.execute(<<~SQL.squish)
        INSERT INTO #{table} (#{columns.join(', ')})
        VALUES #{values.join(', ')} AS new_values
        ON DUPLICATE KEY UPDATE #{updates.join(', ')}
      SQL
    end
  end
end
