# frozen_string_literal: true

# This is the model for version 1 of our ValidatorScore. This model will
# maintain scores for each validator and also maintain a recent history of
# events that can be used for charting or quick analysis. Factors that go into
# building the score are (representative values are shown. Subject to change):
#
# - root_distance: [0, 1, 2] based on cluster median & average
# - vote_distance: [0, 1, 2] based on cluster median & average
# - skipped_slot_percent: [0, 1, 2] based on cluster median & average
# - skipped_after_percent: [0, 1, 2] based on cluster median & average
# - software_version: 2 = current patch, 1 = current minor, 0 = major or N/A
#
# Factors that will be deducted from score above:
# - High percent of total stake. We want to encourage decentralization.
#   Delegated stake > 3% = -2
# - Located in high-concentration data center. Located with 3% stake of other
#   stakeholders = -1, 6% = -2
class ValidatorScoreV1 < ApplicationRecord
  belongs_to :validator

  serialize :root_distance_history, JSON
  serialize :vote_distance_history, JSON
  serialize :skipped_slot_history, JSON
  serialize :skipped_after_history, JSON

  def avg_root_distance_history
    array_average(root_distance_history)
  end

  def avg_vote_distance_history
    array_average(vote_distance_history)
  end

  def root_distance_history_push(val)
    self.root_distance_history = [] if root_distance_history.nil?

    root_distance_history << val
    # TODO: Prune array records. Keep the NNNN most recent
  end

  def vote_distance_history_push(val)
    self.vote_distance_history = [] if vote_distance_history.nil?

    vote_distance_history << val
    # TODO: Prune array records. Keep the NNNN most recent
  end
end
