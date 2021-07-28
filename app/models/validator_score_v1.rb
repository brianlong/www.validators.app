# frozen_string_literal: true

# This is the model for version 1 of our ValidatorScore. This model will
# maintain scores for each validator and also maintain a recent history of
# events that can be used for charting or quick analysis. Factors that go into
# building the score are (representative values are shown. Subject to change):

# Factors that will be deducted from score above:
# - High percent of total stake. We want to encourage decentralization.
#   Delegated stake > 3% = -2
# - Located in high-concentration data center. Located with 3% stake of other
#   stakeholders = -1, 6% = -2
#
# Max score is currently eleven (11)

# == Schema Information
#
# Table name: validator_score_v1s
#
#  id                                          :bigint           not null, primary key
#  active_stake                                :bigint           unsigned
#  commission                                  :integer
#  data_center_concentration                   :decimal(10, 3)
#  data_center_concentration_score             :integer
#  data_center_host                            :string(191)
#  data_center_key                             :string(191)
#  delinquent                                  :boolean
#  ip_address                                  :string(191)
#  network                                     :string(191)
#  ping_time_avg                               :decimal(10, 3)
#  published_information_score                 :integer
#  root_distance_history                       :text(65535)
#  root_distance_score                         :integer
#  security_report_score                       :integer
#  skipped_after_history                       :text(65535)
#  skipped_after_score                         :integer
#  skipped_slot_history                        :text(65535)
#  skipped_slot_moving_average_history         :text(65535)
#  skipped_slot_score                          :integer
#  skipped_vote_history                        :text(65535)
#  skipped_vote_percent_moving_average_history :text(65535)
#  software_version                            :string(191)
#  software_version_score                      :integer
#  stake_concentration                         :decimal(10, 3)
#  stake_concentration_score                   :integer
#  total_score                                 :integer
#  vote_distance_history                       :text(65535)
#  vote_distance_score                         :integer
#  created_at                                  :datetime         not null
#  updated_at                                  :datetime         not null
#  validator_id                                :bigint
#
# Indexes
#
#  index_validator_score_v1s_on_network_and_data_center_key  (network,data_center_key)
#  index_validator_score_v1s_on_validator_id                 (validator_id)
#
class ValidatorScoreV1 < ApplicationRecord
  MAX_HISTORY = 2_880
  IP_FIELDS_FOR_API = [
    'traits_autonomous_system_number', 'address'
  ].map{ |e| "ips.#{e}" }.join(', ')

  # Touch the related validator to increment the updated_at attribute
  belongs_to :validator
  before_save :calculate_total_score
  has_one :ip_for_api, -> { select(IP_FIELDS_FOR_API) }, class_name: 'Ip', primary_key: :ip_address, foreign_key: :address

  after_save :create_commission_history, :if => :saved_change_to_commission?

  serialize :root_distance_history, JSON
  serialize :vote_distance_history, JSON
  serialize :skipped_slot_history, JSON
  serialize :skipped_after_history, JSON
  serialize :skipped_vote_history, JSON
  serialize :skipped_vote_percent_moving_average_history, JSON
  serialize :skipped_slot_moving_average_history, JSON

  scope :by_network_with_active_stake, ->(network) do
    where(network: network).where('active_stake > 0')
  end

  scope :by_data_centers, ->(data_center_keys) do
    where(data_center_key: data_center_keys)
  end

  def create_commission_history
    CreateCommissionHistoryService.new(self).call
  end

  def calculate_total_score
    # Assign special scores before calculating the total score
    best_sw = Batch.last_scored(network)&.software_version
    assign_published_information_score
    assign_software_version_score(best_sw)
    assign_security_report_score

    self.total_score =
      if validator.private_validator?
        0
      else
        root_distance_score.to_i +
          vote_distance_score.to_i +
          skipped_slot_score.to_i +
          published_information_score.to_i +
          security_report_score.to_i +
          software_version_score.to_i +
          stake_concentration_score.to_i +
          data_center_concentration_score.to_i
      end
  end

  def delinquent?
    delinquent == true
  end

  # Evaluate the software version and assign a score
  def assign_software_version_score(best_version)
    if software_version.blank?
      self.software_version_score = 0
      return
    end

    return unless ValidatorSoftwareVersion.valid_software_version?(software_version)
    version = ValidatorSoftwareVersion.new(
      number: software_version,
      network: validator.network,
      best_version: best_version
    )

    self.software_version_score = \
      if version.running_latest_or_newer?
        2
      elsif version.running_latest_major_and_minor_or_newer?
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

    # Prune the array to include the most recent values
    if root_distance_history.length > MAX_HISTORY
      self.root_distance_history = root_distance_history[-MAX_HISTORY..-1]
    end
  end

  def skipped_vote_percent_moving_average_history_push(val)
    self.skipped_vote_percent_moving_average_history = [] if skipped_vote_percent_moving_average_history.nil?
    skipped_vote_percent_moving_average_history << val
    if skipped_vote_percent_moving_average_history.length > MAX_HISTORY
      self.skipped_vote_percent_moving_average_history = skipped_vote_percent_moving_average_history[-MAX_HISTORY..-1]
    end
  end

  def skipped_vote_history_push(val)
    self.skipped_vote_history = [] if skipped_vote_history.nil?
    skipped_vote_history << val
    if skipped_vote_history.length > MAX_HISTORY
      self.skipped_vote_history = skipped_vote_history[-MAX_HISTORY..-1]
    end
  end

  def vote_distance_history_push(val)
    self.vote_distance_history = [] if vote_distance_history.nil?
    vote_distance_history << val
    if vote_distance_history.length > MAX_HISTORY
      self.vote_distance_history = vote_distance_history[-MAX_HISTORY..-1]
    end
  end

  def skipped_slot_history_push(val)
    self.skipped_slot_history = [] if skipped_slot_history.nil?
    skipped_slot_history << val
    if skipped_slot_history.length > MAX_HISTORY
      self.skipped_slot_history = skipped_slot_history[-MAX_HISTORY..-1]
    end
  end

  def skipped_slot_moving_average_history_push(val)
    self.skipped_slot_moving_average_history = [] if skipped_slot_moving_average_history.nil?

    skipped_slot_moving_average_history << val

    if skipped_slot_moving_average_history.length > MAX_HISTORY
      self.skipped_slot_moving_average_history = skipped_slot_moving_average_history[-MAX_HISTORY..-1]
    end
  end
end
