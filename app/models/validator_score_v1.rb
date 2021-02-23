# frozen_string_literal: true

# == Schema Information
#
# Table name: validator_score_v1s
#
#  id                              :bigint           not null, primary key
#  validator_id                    :bigint
#  total_score                     :integer
#  root_distance_history           :text(65535)
#  root_distance_score             :integer
#  vote_distance_history           :text(65535)
#  vote_distance_score             :integer
#  skipped_slot_history            :text(65535)
#  skipped_slot_score              :integer
#  skipped_after_history           :text(65535)
#  skipped_after_score             :integer
#  software_version                :string(255)
#  software_version_score          :integer
#  stake_concentration             :decimal(10, 3)
#  stake_concentration_score       :integer
#  data_center_concentration       :decimal(10, 3)
#  data_center_concentration_score :integer
#  active_stake                    :bigint           unsigned
#  commission                      :integer
#  ping_time_avg                   :decimal(10, 3)
#  delinquent                      :boolean
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  published_information_score     :integer
#  security_report_score           :integer
#  ip_address                      :string(255)
#  network                         :string(255)
#  data_center_key                 :string(255)
#  data_center_host                :string(255)
#
# This is the model for version 1 of our ValidatorScore. This model will
# maintain scores for each validator and also maintain a recent history of
# events that can be used for charting or quick analysis. Factors that go into
# building the score are (representative values are shown. Subject to change):
#
# - root_distance: [0, 1, 2] based on cluster median & average
# - vote_distance: [0, 1, 2] based on cluster median & average
# - skipped_slot_percent: [0, 1, 2] based on cluster median & average
# - software_version: 2 = current patch, 1 = current minor, 0 = major or N/A
# - published_information_score: [0, 1, 2] 2 = published 4 info elements to the
#     chain. 1 = published 2 or 3 elements, 0 = published 0 or 1 element.
# - security_report_score: [0,1] = no url published. 1 = url is published
#
# Factors that will be deducted from score above:
# - High percent of total stake. We want to encourage decentralization.
#   Delegated stake > 3% = -2
# - Located in high-concentration data center. Located with 3% stake of other
#   stakeholders = -1, 6% = -2
#
# Max score is currently eleven (11)
class ValidatorScoreV1 < ApplicationRecord
  MAX_HISTORY = 2_880

  # Touch the related validator to increment the updated_at attribute
  belongs_to :validator
  before_save :calculate_total_score

  serialize :root_distance_history, JSON
  serialize :vote_distance_history, JSON
  serialize :skipped_slot_history, JSON
  serialize :skipped_after_history, JSON

  def calculate_total_score
    # Assign special scores before calculating the total score
    assign_published_information_score
    assign_software_version_score
    assign_security_report_score

    self.total_score = root_distance_score.to_i +
                       vote_distance_score.to_i +
                       skipped_slot_score.to_i +
                       published_information_score.to_i +
                       security_report_score.to_i +
                       software_version_score.to_i +
                       stake_concentration_score.to_i +
                       data_center_concentration_score.to_i
  end

  def delinquent?
    delinquent == true
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

  # Assign a score based on published information. We assign 1/2 point for each
  # element of published information. After assigning the individual scores, we
  # round down to the nearest integer. 1 point if there are two or three pieces
  # of data. 2 points if all for elements are not blank.
  def assign_published_information_score
    sc = 0.0
    sc += validator.name.blank? ? 0.0 : 0.5
    sc += validator.keybase_id.blank? ? 0.0 : 0.5
    sc += validator.www_url.blank? ? 0.0 : 0.5
    sc += validator.details.blank? ? 0.0 : 0.5
    self.published_information_score = sc.floor
  end

  # Assign one point if the validator has provided a security_report_url
  def assign_security_report_score
    self.security_report_score = validator.security_report_url.blank? ? 0 : 1
  end

  def avg_root_distance_history
    array_average(root_distance_history)
  end

  def med_root_distance_history
    array_median(root_distance_history)
  end

  def avg_vote_distance_history
    array_average(vote_distance_history)
  end

  def med_vote_distance_history
    array_median(vote_distance_history)
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
end
