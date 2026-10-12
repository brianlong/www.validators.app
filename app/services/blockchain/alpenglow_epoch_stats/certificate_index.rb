# frozen_string_literal: true

module Blockchain
  module AlpenglowEpochStats
    class CertificateIndex
      def initialize(footer_class:, footers:)
        @footer_class = footer_class
        @footers = footers
      end

      def call
        already_seen = previously_seen

        CERTIFICATES.to_h do |type, column|
          firsts = {}
          @footers.each do |footer|
            slot = footer.public_send(column)
            next if slot.nil? || already_seen[type].include?(slot) || firsts.key?(slot)

            firsts[slot] = footer
          end
          [type, firsts]
        end
      end

      private

      def previously_seen
        first_slot = @footers.first.slot_number
        rows = @footer_class.where(slot_number: (first_slot - DEDUP_WINDOW)...first_slot).pluck(*CERTIFICATES.values)

        CERTIFICATES.keys.each_with_index.to_h do |type, index|
          [type, rows.map { |values| values[index] }.compact.to_set]
        end
      end
    end
  end
end
