# frozen_string_literal: true

module Blockchain
  class BlockFooterSaveService
    USER_AGENT_LIMIT = 191

    def initialize(network:, footers:, epoch_schedule:, leader_schedule:)
      @network = network
      @footers = footers
      @epoch_schedule = epoch_schedule
      @leader_schedule = leader_schedule
    end

    def call
      return 0 if @footers.empty?

      now = Time.current
      rows = @footers.map { |footer| row(footer, now) }.index_by { |row| row[:slot_number] }.values
      Blockchain::BlockFooter.network(@network).upsert_all(rows)
      rows.size
    end

    private

    def row(footer, now)
      final_cert = footer[:block_final_cert]
      notar_reward_cert = footer[:notar_reward_cert]
      skip_reward_cert = footer[:skip_reward_cert]

      {
        slot_number: footer[:slot],
        epoch: @epoch_schedule.epoch_for(footer[:slot]),
        leader: @leader_schedule.leader_for(footer[:slot]),
        bank_id: footer[:bank_id],
        bank_hash: footer[:bank_hash],
        block_producer_time_nanos: footer[:block_producer_time_nanos],
        block_user_agent: footer[:block_user_agent].presence&.first(USER_AGENT_LIMIT),
        final_cert_slot: final_cert&.dig(:slot),
        finalization: final_cert && Blockchain::BlockFooter.finalizations.fetch(final_cert[:finalization]),
        final_signers: final_cert&.dig(:final_signers),
        final_notar_signers: final_cert&.dig(:notar_signers),
        notar_reward_slot: notar_reward_cert&.dig(:slot),
        notar_reward_signers: notar_reward_cert&.dig(:signers),
        skip_reward_slot: skip_reward_cert&.dig(:slot),
        skip_reward_signers: skip_reward_cert&.dig(:signers),
        created_at: now,
        updated_at: now
      }
    end
  end
end
