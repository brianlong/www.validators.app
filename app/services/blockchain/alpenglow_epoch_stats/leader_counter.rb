# frozen_string_literal: true

module Blockchain
  module AlpenglowEpochStats
    class LeaderCounter
      attr_reader :counters

      def initialize(footer_class:)
        @footer_class = footer_class
        @counters = AlpenglowEpochStats.new_counters
      end

      def call(footers, final_certificates)
        count_produced_blocks(footers)
        count_finalizations(final_certificates)
        self
      end

      private

      def count_produced_blocks(footers)
        footers.each do |footer|
          next if footer.leader.blank?

          key = [footer.epoch, footer.leader]
          @counters[key][:leader_slots] += 1
          @counters[key][:leader_slots_with_final_cert] += 1 if footer.final_cert_slot
        end
      end

      def count_finalizations(final_certificates)
        @footer_class.where(slot_number: final_certificates.keys).pluck(:slot_number, :epoch, :leader).each do |slot, epoch, leader|
          next if leader.blank?

          footer = final_certificates[slot]
          key = [epoch, leader]
          @counters[key][footer.fast? ? :leader_fast_finalized : :leader_slow_finalized] += 1
          @counters[key][:leader_final_lag_sum] += footer.slot_number - slot
        end
      end
    end
  end
end
