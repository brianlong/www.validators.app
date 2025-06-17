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
#  authorized_withdrawer_score                 :integer
#  commission                                  :integer
#  consensus_mods_score                        :integer          default(0)
#  data_center_concentration                   :decimal(10, 3)
#  data_center_concentration_score             :integer
#  delinquent                                  :boolean
#  ip_address                                  :string(191)
#  network                                     :string(191)
#  ping_time_avg                               :decimal(10, 3)
#  published_information_score                 :integer
#  root_distance_history                       :text(65535)
#  root_distance_score                         :integer
#  security_report_score                       :integer
#  skipped_after_history                       :text(65535)
#  skipped_after_moving_average_history        :text(65535)
#  skipped_after_score                         :integer
#  skipped_slot_history                        :text(65535)
#  skipped_slot_moving_average_history         :text(65535)
#  skipped_slot_score                          :integer
#  skipped_vote_history                        :text(65535)
#  skipped_vote_percent_moving_average_history :text(65535)
#  software_client                             :integer          default(0)
#  software_version                            :string(191)
#  software_version_score                      :integer
#  stake_concentration                         :decimal(10, 3)
#  stake_concentration_score                   :integer
#  total_score                                 :integer
#  vote_distance_history                       :text(65535)
#  vote_distance_score                         :integer
#  vote_latency_history                        :text(65535)
#  vote_latency_score                          :integer
#  created_at                                  :datetime         not null
#  updated_at                                  :datetime         not null
#  validator_id                                :bigint
#
# Indexes
#
#  index_for_asns                                         (network,active_stake,commission,delinquent)
#  index_validator_score_v1s_on_network_and_total_score   (network,total_score)
#  index_validator_score_v1s_on_network_and_validator_id  (network,validator_id)
#
class ValidatorScoreV1 < ApplicationRecord
  FIELDS_FOR_API = %i[
    active_stake
    authorized_withdrawer_score
    commission
    data_center_concentration_score
    delinquent
    published_information_score
    root_distance_score
    security_report_score
    skipped_slot_score
    skipped_after_score
    software_version
    software_version_score
    stake_concentration_score
    consensus_mods_score
    vote_latency_score
    total_score
    validator_id
    vote_distance_score
    software_client
  ].freeze

  FIELDS_FOR_VALIDATORS_INDEX_WEB = %i[
    active_stake
    total_score
    validator_id
  ].freeze

  HISTORY_FIELDS = %i[
    root_distance_history
    vote_distance_history
    skipped_slot_history
    skipped_vote_history
    skipped_slot_moving_average_history
    skipped_after_moving_average_history
    stake_concentration
    skipped_after_history
    vote_latency_history
  ].freeze

  WITHDRAWER_SCORE_OPTIONS = {
    negative: -2,
    neutral: 0
  }.freeze

  MAX_HISTORY = 2_880

  ATTRIBUTES_FOR_BUILDER = (FIELDS_FOR_API - [:validator_id]).freeze

  enum software_client: { agave: 0, firedancer: 1 }

  # Touch the related validator to increment the updated_at attribute
  after_save :create_commission_history, :if => :saved_change_to_commission?
  before_save :calculate_total_score

  belongs_to :validator
  has_many :validator_ips, through: :validator
  has_one :validator_ip_active, through: :validator
  has_one :data_center, through: :validator

  serialize :root_distance_history, JSON
  serialize :vote_distance_history, JSON
  serialize :skipped_slot_history, JSON
  serialize :skipped_after_history, JSON
  serialize :skipped_vote_history, JSON
  serialize :skipped_vote_percent_moving_average_history, JSON
  serialize :skipped_slot_moving_average_history, JSON
  serialize :skipped_after_moving_average_history, JSON
  serialize :vote_latency_history, JSON

  delegate :data_center, to: :validator, prefix: true, allow_nil: true

  scope :by_network_with_active_stake, ->(network) do
    where(network: network).where('active_stake > 0')
  end

  scope :by_data_centers, ->(data_center_keys) do
    select_statement = "validator_score_v1s.*, data_centers.data_center_key"

    select(select_statement).joins(:data_center)
                            .where("data_centers.data_center_key = ?", data_center_keys)
  end

  scope :for_api, -> { select(FIELDS_FOR_API) }
  scope :for_web, -> { select(FIELDS_FOR_VALIDATORS_INDEX_WEB) }

  def create_commission_history
    CreateCommissionHistoryService.new(self).call
  end

  class << self
    def with_private(show: "true")
      show == "true" ? all : where.not(commission: 100)
    end

    def total_active_stake(network)
      joins(:data_center).by_network_with_active_stake(network).sum(:active_stake)
    end
  end

  def calculate_total_score
    # Assign special scores before calculating the total score
    best_sv = Batch.last_scored(network)&.software_versions
    assign_published_information_score
    assign_software_version_score(best_sv)
    assign_security_report_score
    assign_consensus_mods_score
    assign_vote_latency_score

    self.total_score =
      if validator.private_validator? || validator.admin_warning
        0
      else
        root_distance_score.to_i +
          vote_distance_score.to_i +
          skipped_slot_score.to_i +
          published_information_score.to_i +
          security_report_score.to_i +
          consensus_mods_score.to_i +
          software_version_score.to_i +
          stake_concentration_score.to_i +
          data_center_concentration_score.to_i +
          authorized_withdrawer_score.to_i +
          vote_latency_score.to_i
      end
  end

  def displayed_total_score
    return "N/A" if validator.private_validator?
    return "N/A" if validator.admin_warning
    total_score
  end

  def delinquent?
    delinquent == true
  end

  # Evaluate the software version and assign a score
  def assign_software_version_score(best_versions)
    if software_version.blank?
      self.software_version_score = 0
      return
    end

    return unless ValidatorSoftwareVersion.valid_software_version?(software_version) && best_versions

    best_version = best_versions[software_client]

    version = ValidatorSoftwareVersion.new(number: software_version, network: validator.network, best_version: best_version)

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
    sc += validator.avatar_url.blank? ? 0.0 : 0.5
    sc += validator.www_url.blank? ? 0.0 : 0.5
    sc += validator.details.blank? ? 0.0 : 0.5
    self.published_information_score = sc.floor
  end

  # Assign one point if the validator has provided a security_report_url
  # Assign 0 if consensus_mods value is true
  def assign_security_report_score
    return self.security_report_score = 0 if validator.consensus_mods
    self.security_report_score = validator.security_report_url.blank? ? 0 : 1
  end

  # Assign -2 if consensus_mods value is true
  def assign_consensus_mods_score
    self.consensus_mods_score = validator.consensus_mods ? -2 : 0
  end

  def assign_vote_latency_score
    return 0 if vote_latency_history.blank?

    self.vote_latency_score = case vote_latency_history.last
                              when 0...2 then 2
                              when 2..3 then 1
                              else 0
                              end
  end

  def avg_root_distance_history(period = nil)
    period ? array_average(root_distance_history.last(period)) : array_average(root_distance_history)
  end

  def med_root_distance_history(period = nil)
    period ? array_median(root_distance_history.last(period)) : array_median(root_distance_history)
  end

  def avg_vote_distance_history(period = nil)
    period ? array_average(vote_distance_history.last(period)) : array_average(vote_distance_history)
  end

  def med_vote_distance_history(period = nil)
    period ? array_median(vote_distance_history.last(period)) : array_median(vote_distance_history)
  end

  def skipped_after_history_push(val)
    self.skipped_after_history = [] if skipped_after_history.nil?

    skipped_after_history << val

    # Prune the array  to include the most recent values
    if skipped_after_history.length > MAX_HISTORY
      self.skipped_after_history = skipped_after_history[-MAX_HISTORY..-1]
    end
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

  def skipped_after_moving_average_history_push(val)
    self.skipped_after_moving_average_history = [] if skipped_after_moving_average_history.nil?

    skipped_after_moving_average_history << val

    if skipped_after_moving_average_history.length > MAX_HISTORY
      self.skipped_after_moving_average_history = skipped_after_moving_average_history[-MAX_HISTORY..-1]
    end
  end

  def vote_latency_history_push(val)
    self.vote_latency_history = [] if vote_latency_history.nil?
    vote_latency_history << val
    if vote_latency_history.length > MAX_HISTORY
      self.vote_latency_history = vote_latency_history[-MAX_HISTORY..-1]
    end
  end

  def to_builder(with_history: false)
    Jbuilder.new do |vs_v1|
      if with_history
        vs_v1.(
          self,
          *(ATTRIBUTES_FOR_BUILDER + HISTORY_FIELDS)
        )
      else
        vs_v1.(
          self,
          *ATTRIBUTES_FOR_BUILDER
        )
      end
    end
  end
end
