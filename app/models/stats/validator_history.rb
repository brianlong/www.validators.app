# frozen_string_literal: true

module Stats

  # ValidatorHistory set of stats scoped to certain batch.
  #
  # Usage: stats = Stats::ValidatorHistory.new(network, batch_uuid)
  #            # network    - 'testnet', 'mainnet' or 'pythnet' atm
  #            # batch_uuid - batch in which look for
  #        stats.average_root_block
  #        stats.highest_root_block
  #        stats.median_root_block
  #        stats.average_last_vote
  #        ...
  class ValidatorHistory < ApplicationStats
    def initialize(network, batch_uuid)
      super

      @relation = ::ValidatorHistory.for_batch(network, batch_uuid)
    end

    # Mysql AVG is so far the fastest way to count average (compared to pluck and map)
    def average_root_block
      @average_root_block ||= relation.average(:root_block)
    end

    def highest_root_block
      @highest_root_block ||= relation.maximum(:root_block)
    end

    def median_root_block
      @median_root_block ||= relation.median(:root_block)
    end

    def average_last_vote
      @average_last_vote ||= relation.average(:last_vote)
    end

    def highest_last_vote
      @highest_last_vote ||= relation.maximum(:last_vote)
    end

    def median_last_vote
      @median_last_vote ||= relation.pluck(:last_vote).median
    end

    def total_active_stake
      @total_active_stake ||= relation.sum(:active_stake)
    end

    # Lists all the ValidatorHistories that collects top 33% of the
    # all active stakes
    def upto_33_stake
      return @upto_33_stake if @upto_33_stake

      active_stakes_sum = 0
      validator_ids = []
      active_stakes = relation.order(active_stake: :desc)
                              .pluck(:id, :active_stake)

      active_stakes.each do |id, active_stake|
        active_stakes_sum += active_stake
        validator_ids << id

        break if over_33_of_total?(active_stakes_sum)
      end

      @upto_33_stake =
        ::ValidatorHistory.where(id: validator_ids).order(active_stake: :desc)
    end

    # ValidatorHistory on the edge of top 33% stakes
    def at_33_stake
      @at_33_stake ||= upto_33_stake.last
    end

    private

    def over_33_of_total?(value)
      value > (total_active_stake / 3.0)
    end
  end
end
