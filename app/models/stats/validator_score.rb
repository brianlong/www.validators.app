# frozen_string_literal: true

module Stats

  # ValidatorScore set of stats scoped to certain batch.
  #
  # Usage: stats = Stats::ValidatorScore.new(network, batch_uuid)
  #            # network    - 'testnet', 'mainnet' or 'pythnet' atm
  #            # batch_uuid - batch in which look for
  #        stats.root_distance_all_history
  #        stats.root_distance_all_averages
  #        stats.top_root_distance_averages_validators
  #        stats.root_distance_stats(with_history: false)
  #        ...
  class ValidatorScore < ApplicationStats
    def initialize(network, batch_uuid)
      super

      @relation = ValidatorScoreQuery.new(network, batch_uuid)
                                     .for_batch
    end

    def root_distance_all_history
      @root_distance_all_history ||= relation.joins(:validator)
                                             .pluck(:root_distance_history, :account)
    end

    def root_distance_all_averages
      @root_distance_all_averages ||= root_distance_all_history&.last(960).map do |root_dist|
        begin
          [root_dist.first.average, root_dist.last]
        rescue NoMethodError
          nil
        end
      end
      
      @root_distance_all_averages.compact
    end

    def top_root_distance_averages_validators
      @top_root_distance_averages_validators ||= root_distance_all_averages&.sort&.first(50)
    end

    def root_distance_stats(with_history: false)
      root_distance_stats = {
        min: root_distance_all_averages&.map(&:first)&.min,
        max: root_distance_all_averages&.map(&:first)&.max,
        median: root_distance_all_averages&.map(&:first)&.median,
        average: root_distance_all_averages&.map(&:first)&.average
      }

      return root_distance_stats unless with_history

      root_distance_stats.merge({ history: root_distance_all_history })
    end

    def vote_distance_all_history
      @vote_distance_all_history ||= relation&.joins(:validator)&.pluck(:vote_distance_history, :account)
    end

    def vote_distance_all_averages
      @vote_distance_all_averages ||= vote_distance_all_history&.last(960).map do |vote_dist|
        begin 
          [vote_dist.first.average, vote_dist.last]
        rescue NoMethodError
          nil
        end
      end

      @vote_distance_all_averages.compact
    end

    def top_vote_distance_averages_validators
      @top_vote_distance_averages_validators ||= vote_distance_all_averages&.sort&.first(50)
    end

    def top_staked_validators
      @top_staked_validators ||= relation.joins(:validator)
                                         .pluck(:active_stake, :account)
                                         .map { |tsv| [tsv.first.to_i, tsv.last] }
                                         .sort
                                         .reverse
                                         .first(50)
    end

    def total_stake
      @total_stake ||= relation.pluck(:active_stake).map(&:to_i).sum
    end

    def vote_distance_stats(with_history: false)
      vote_distance_stats = {
        min: vote_distance_all_averages&.map(&:first)&.min,
        max: vote_distance_all_averages&.map(&:first)&.max,
        median: vote_distance_all_averages&.map(&:first)&.median,
        average: vote_distance_all_averages&.map(&:first)&.average
      }

      return vote_distance_stats unless with_history

      vote_distance_stats.merge({ history: vote_distance_all_history })
    end
  end
end
