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
  MAX_HISTORY = 2_880

  belongs_to :validator
  before_save :calculate_total_score

  serialize :root_distance_history, JSON
  serialize :vote_distance_history, JSON
  serialize :skipped_slot_history, JSON
  serialize :skipped_after_history, JSON

  def calculate_total_score
    self.total_score = root_distance_score.to_i +
                       vote_distance_score.to_i +
                       skipped_slot_score.to_i +
                       skipped_after_score.to_i +
                       software_version_score.to_i +
                       stake_concentration_score.to_i +
                       data_center_concentration_score.to_i
  end

  # Evaluate the software version and assign a score
  def assign_software_version_score
    if software_version.blank?
      self.software_version_score = 0
      return
    end

    creds = Rails.application.credentials
    self.software_version_score = \
      if software_version.include?(
        creds.solana["software_patch_#{validator.network}".to_sym].to_s
      )
        2
      elsif software_version.include?(
        creds.solana["software_minor_#{validator.network}".to_sym].to_s
      )
        1
      else
        0
      end
  end

  def avg_root_distance_history
    array_average(root_distance_history)
  end

  def avg_vote_distance_history
    array_average(vote_distance_history)
  end

  def root_distance_history_push(val)
    self.root_distance_history = [] if root_distance_history.nil?

    root_distance_history << val

    # Prune the array  to include the most recent values
    if root_distance_history.length > MAX_HISTORY
      self.root_distance_history = root_distance_history[-MAX_HISTORY..-1]
    end
  end

  def vote_distance_history_push(val)
    self.vote_distance_history = [] if vote_distance_history.nil?

    vote_distance_history << val

    # Prune the array  to include the most recent values
    if vote_distance_history.length > MAX_HISTORY
      self.vote_distance_history = vote_distance_history[-MAX_HISTORY..-1]
    end
  end

  def skipped_slot_history_push(val)
    self.skipped_slot_history = [] if skipped_slot_history.nil?

    skipped_slot_history << val

    # Prune the array  to include the most recent values
    if skipped_slot_history.length > MAX_HISTORY
      self.skipped_slot_history = skipped_slot_history[-MAX_HISTORY..-1]
    end
  end

  def skipped_after_history_push(val)
    self.skipped_after_history = [] if skipped_after_history.nil?

    skipped_after_history << val

    # Prune the array  to include the most recent values
    if skipped_after_history.length > MAX_HISTORY
      self.skipped_after_history = skipped_after_history[-MAX_HISTORY..-1]
    end
  end
end
