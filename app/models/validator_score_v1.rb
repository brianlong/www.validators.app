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
end
