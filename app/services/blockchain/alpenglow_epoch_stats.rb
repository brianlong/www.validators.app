# frozen_string_literal: true

module Blockchain
  module AlpenglowEpochStats
    DEDUP_WINDOW = 64

    LEADER_COUNTERS = %i[
      leader_slots
      leader_slots_with_final_cert
      leader_fast_finalized
      leader_slow_finalized
      leader_final_lag_sum
    ].freeze

    VOTING_COUNTERS = %i[
      notar_reward_slots
      notar_votes
      fast_finalized_slots
      fast_final_signatures
      slow_finalized_slots
      slow_final_signatures
      slow_notar_signatures
      skip_votes
      divergent_skip_votes
    ].freeze

    COUNTERS = (LEADER_COUNTERS + VOTING_COUNTERS).freeze

    CERTIFICATES = {
      final: :final_cert_slot,
      notar_reward: :notar_reward_slot,
      skip_reward: :skip_reward_slot
    }.freeze

    def self.new_counters
      Hash.new { |hash, key| hash[key] = Hash.new(0) }
    end
  end
end
