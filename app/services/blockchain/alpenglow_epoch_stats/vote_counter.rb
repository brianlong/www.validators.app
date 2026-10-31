# frozen_string_literal: true

module Blockchain
  module AlpenglowEpochStats
    class VoteCounter
      attr_reader :counters

      def initialize(network:, footer_class:, epoch_schedule:)
        @network = network
        @footer_class = footer_class
        @epoch_schedule = epoch_schedule
        @counters = AlpenglowEpochStats.new_counters
      end

      def call(certificates)
        @ranks = verified_ranks(certificates)
        count_notar_rewards(certificates[:notar_reward])
        count_finalizations(certificates[:final])
        count_skips(certificates[:skip_reward])
        self
      end

      private

      def count_notar_rewards(certificates)
        certificates.each do |slot, footer|
          each_ranked(slot) do |epoch, vote_accounts|
            increment(epoch, vote_accounts, :notar_reward_slots)
            increment(epoch, signers(vote_accounts, footer.notar_reward_signers), :notar_votes)
          end
        end
      end

      def count_finalizations(certificates)
        certificates.each do |slot, footer|
          each_ranked(slot) do |epoch, vote_accounts|
            kind = footer.fast? ? :fast : :slow
            increment(epoch, vote_accounts, :"#{kind}_finalized_slots")
            increment(epoch, signers(vote_accounts, footer.final_signers), :"#{kind}_final_signatures")
            increment(epoch, signers(vote_accounts, footer.final_notar_signers), :slow_notar_signatures)
          end
        end
      end

      def count_skips(certificates)
        notarized = notarized_slots(certificates.keys)

        certificates.each do |slot, footer|
          each_ranked(slot) do |epoch, vote_accounts|
            skip_voters = signers(vote_accounts, footer.skip_reward_signers)
            increment(epoch, skip_voters, :skip_votes)
            increment(epoch, skip_voters, :divergent_skip_votes) if notarized.include?(slot)
          end
        end
      end

      def increment(epoch, vote_accounts, counter)
        vote_accounts.each { |vote_account| @counters[[epoch, vote_account]][counter] += 1 }
      end

      def verified_ranks(certificates)
        epochs = certificates.values.flat_map(&:keys).map { |slot| @epoch_schedule.epoch_for(slot) }.uniq
        AlpenglowEpochRank.verified.where(network: @network, epoch: epochs).order(:rank)
                          .pluck(:epoch, :vote_account)
                          .group_by(&:first)
                          .transform_values { |rows| rows.map(&:last) }
      end

      def each_ranked(slot)
        epoch = @epoch_schedule.epoch_for(slot)
        vote_accounts = @ranks[epoch]
        yield epoch, vote_accounts if vote_accounts
      end

      def signers(vote_accounts, bytes)
        return [] if bytes.blank?

        decoded = Blockchain::SignerStore.decode(bytes)
        (decoded[:ranks] + decoded.fetch(:fallback_ranks, [])).uniq.filter_map { |rank| vote_accounts[rank] }
      end

      def notarized_slots(skip_slots)
        return Set.new if skip_slots.empty?

        @footer_class.where(slot_number: skip_slots.min..(skip_slots.max + DEDUP_WINDOW))
                     .where(notar_reward_slot: skip_slots)
                     .distinct
                     .pluck(:notar_reward_slot)
                     .to_set
      end
    end
  end
end
