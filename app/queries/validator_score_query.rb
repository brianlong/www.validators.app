# frozen_string_literal: true

# QueryObject class created to extract query class methods from
# ValidatorScoreV1 model.
# Usage:
# Set @relation by network and batch_uuid in which query should run:
#   query = ValidatorScoreQuery.new(network, batch_uuid)
# Call query method on scoped @relation
#   query.for_batch
#   query.
class ValidatorScoreQuery < ApplicationQuery
  def initialize(network, batch_uuid)
    super

    @validators = ValidatorHistoryQuery.new(network, batch_uuid)
                                       .for_batch
                                       .map(&:validator)
                                       .compact
    @relation = ValidatorScoreV1.where(validator_id: @validators.map(&:id))
  end

  def for_batch
    @for_batch ||= @relation
  end

  def root_distance_all_history
    @root_distance_all_history ||=
      for_batch.map(&:root_distance_history)
  end

  def root_distance_all_averages
    @root_distance_all_averages ||=
      root_distance_all_history.map(&:average)
  rescue NoMethodError
    nil
  end

  def top_root_distance_averages_validators
    @top_root_distance_averages_validators ||=
      root_distance_all_averages&.sort&.reverse
  end

  def root_distance_stats(with_history: false)
    root_distance_stats = {
      min: root_distance_all_averages&.min,
      max: root_distance_all_averages&.max,
      median: root_distance_all_averages&.median,
      average: root_distance_all_averages&.average
    }

    return root_distance_stats unless with_history

    root_distance_stats.merge({ history: root_distance_all_history })
  end

  def vote_distance_all_history
    @vote_distance_all_history ||=
      for_batch&.map(&:vote_distance_history)
  end

  def vote_distance_all_averages
    @vote_distance_all_averages ||=
      vote_distance_all_history&.map(&:average)
  rescue NoMethodError
    nil
  end

  def top_vote_distance_averages_validators
    @top_vote_distance_averages_validators ||=
      vote_distance_all_averages&.sort&.reverse
  end

  def top_staked_validators
    # map(&:to_i) handles nils
    @top_staked_validators ||=
      for_batch.pluck(:active_stake).map(&:to_i).sort.reverse

  end

  def vote_distance_stats(with_history: false)
    vote_distance_stats = {
      min: vote_distance_all_averages&.min,
      max: vote_distance_all_averages&.max,
      median: vote_distance_all_averages&.median,
      average: vote_distance_all_averages&.average
    }

    return vote_distance_stats unless with_history

    vote_distance_stats.merge({ history: vote_distance_all_history })
  end
end
