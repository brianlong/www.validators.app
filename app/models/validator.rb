# frozen_string_literal: true

# == Schema Information
#
# Table name: validators
#
#  id                  :bigint           not null, primary key
#  network             :string(255)
#  account             :string(255)
#  name                :string(255)
#  keybase_id          :string(255)
#  www_url             :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  details             :string(255)
#  info_pub_key        :string(255)
#  avatar_url          :string(255)
#  security_report_url :string(255)
#
# Validator
class Validator < ApplicationRecord
  has_many :vote_accounts, dependent: :destroy
  has_many :vote_account_histories, through: :vote_accounts, dependent: :destroy
  has_many :validator_ips, dependent: :destroy
  has_many :validator_block_histories, dependent: :destroy
  has_one :validator_score_v1, dependent: :destroy

  # after_save :copy_data_to_score

  # Returns an Array of account IDs for a given network
  #
  # Validator.accounts_for('testnet') => ['1234', '5678']
  def self.accounts_for(network)
    where(network: network)
      .select('account')
      .map(&:account)
  end

  def validator_history_last
    ValidatorHistory.where(
      network: network,
      account: account
    ).last
  end

  # Return the vote account that was most recently used
  def vote_account_last
    vote_accounts.order('updated_at desc').limit(1).first
  end

  def ping_times_to(limit = 100)
    PingTime.where(
      network: network,
      to_account: account
    ).order('created_at desc').limit(limit)
  end

  def ping_times_to_avg
    ary = ping_times_to.all.map do |pt|
      pt.avg_ms.to_f.round(2)
    end

    return nil if ary.empty?

    ary.sum / ary.length.to_f
  end

  def ip_address
    validator_ips.order('updated_at desc').first&.address
  end

  def copy_data_to_score
    if validator_score_v1
      validator_score_v1.ip_address = ip_address
      ip_dc = Ip.where(address: ip_address).first&.data_center_key
      validator_score_v1.data_center_key = ip_dc
      validator_score_v1.save
    end
  end

  # Convenience methods
  def score
    validator_score_v1
  end

  def delinquent?
    score&.delinquent
  end

  def commission
    score&.commission
  end

  def active_stake
    score&.active_stake || 0
  end

  def stake_concentration
    score&.stake_concentration || 0.0
  end

  def stake_concentration_score
    score&.stake_concentration_score || 0
  end

  def software_version
    score&.software_version
  end

  def tower_blocks_behind_leader
    score&.root_distance_history&.last
  end

  def root_distance_score
    score&.root_distance_score
  end

  def tower_votes_behind_leader
    score&.vote_distance_history&.last
  end

  def vote_distance_score
    score&.vote_distance_score
  end

  def skipped_slot_history
    score&.skipped_slot_history
  end

  def skipped_slot_percent
    score&.skipped_slot_history&.last
  end

  def skipped_slot_score
    score&.skipped_slot_score
  end

  def ping_time_avg
    score&.ping_time_avg
  end

  def software_version_score
    score&.software_version_score
  end

  def published_information_score
    score&.published_information_score
  end

  def security_report_score
    score&.security_report_score
  end

  def total_score
    score&.total_score
  end

  def data_center_key
    score&.data_center_key
  end

  def data_center_concentration
    score&.data_center_concentration || 0.0
  end

  def data_center_concentration_score
    score&.data_center_concentration_score || 0
  end
end
