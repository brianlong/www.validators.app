module Stats
  class ValidatorHistory < ApplicationStats
    def initialize(network, batch_uuid)
      super

      @relation = ValidatorHistoryQuery.new(network, batch_uuid)
                                       .for_batch
    end

    # Mysql AVG is so far the fastest way to count average (compared to pluck and map)
    def average_root_block
      @average_root_block ||= for_batch.average(:root_block)
    end

    def highest_root_block
      @highest_root_block ||= for_batch.maximum(:root_block)
    end

    def median_root_block
      @median_root_block ||= for_batch.median(:root_block)
    end

    def average_last_vote
      @average_last_vote ||= for_batch.average(:last_vote)
    end

    def highest_last_vote
      @highest_last_vote ||= for_batch.maximum(:last_vote)
    end

    def median_last_vote
      @median_last_vote ||= for_batch.pluck(:last_vote).median
    end

    def total_active_stake
      @total_active_stake ||= for_batch.sum(:active_stake)
    end

    # Lists all the ValidatorHistories that collects top 33% of the
    # all active stakes
    def upto_33_stake
      return @upto_33_stake if @upto_33_stake

      active_stakes_sum = 0
      validator_ids = []
      active_stakes = for_batch.order(active_stake: :desc)
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

    def for_batch
      @for_batch ||= @relation
    end
  end
end
