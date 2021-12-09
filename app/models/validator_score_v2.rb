# frozen_string_literal: true

# This is the model for version 2 of our ValidatorScore. This model will maintain scores for each
# validator and also maintain a recent history of events that can be used for charting or quick analysis.
# Factors that go into building the score are described in docs file:
# app/views/public/faq.en.html.erb
#
#
# == Schema Information
#
# Table name: validator_score_v2s
#
#  id                                          :bigint           not null, primary key
#  active_stake                                :bigint           unsigned
#  authorized_withdrawer_score                 :integer
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
#  skipped_slot_history                        :text(65535)
#  skipped_slot_moving_average_history         :text(65535)
#  skipped_slot_score                          :integer
#  skipped_vote_history                        :text(65535)
#  skipped_vote_percent_moving_average_history :text(65535)
#  skipped_vote_score                          :integer
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
#  index_validator_score_v2s_on_network_and_data_center_key  (network,data_center_key)
#  index_validator_score_v2s_on_validator_id                 (validator_id)
#

class ValidatorScoreV2 < ApplicationRecord
  # IP_FIELDS_FOR_API = [
  #   "traits_autonomous_system_number", "address"
  # ].map{ |e| "ips.#{e}" }.join(", ")

  belongs_to :validator
  has_one :validator_score_v1, through: :validator
  before_save :calculate_total_score
  # has_one :ip_for_api, -> { select(IP_FIELDS_FOR_API) }, class_name: "Ip",
  #                                                        primary_key: :ip_address,
  #                                                        foreign_key: :address

  scope :by_network_with_active_stake, ->(network) do
    where(network: network).where("active_stake > 0")
  end

  scope :by_data_centers, ->(data_center_keys) do
    where(data_center_key: data_center_keys)
  end

  def calculate_total_score
    self.total_score =
      if validator.private_validator?
        0
      else
        root_distance_score.to_i +
          vote_distance_score.to_i +
          skipped_slot_score.to_i +
          validator_score_v1.published_information_score.to_i +
          validator_score_v1.security_report_score.to_i +
          validator_score_v1.software_version_score.to_i +
          validator_score_v1.stake_concentration_score.to_i +
          validator_score_v1.data_center_concentration_score.to_i
      end
  end

  def delinquent?
    validator_score_v1.delinquent == true
  end

  # def to_builder
  #   Jbuilder.new do |vs_v2|
  #     vs_v2.(
  #       self,
  #       :total_score,
  #       :root_distance_score,
  #       :vote_distance_score,
  #       :skipped_slot_score,
  #       :software_version,
  #       :software_version_score,
  #       :stake_concentration_score,
  #       :data_center_concentration_score,
  #       :published_information_score,
  #       :security_report_score,
  #       :active_stake,
  #       :commission,
  #       :delinquent,
  #       :data_center_key,
  #       :data_center_host
  #     )
  #   end
  # end
end
