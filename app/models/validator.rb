# frozen_string_literal: true

# == Schema Information
#
# Table name: validators
#
#  id                  :bigint           not null, primary key
#  account             :string(191)
#  admin_warning       :string(191)
#  avatar_url          :string(191)
#  details             :string(191)
#  info_pub_key        :string(191)
#  is_active           :boolean          default(TRUE)
#  is_destroyed        :boolean          default(FALSE)
#  is_rpc              :boolean          default(FALSE)
#  name                :string(191)
#  network             :string(191)
#  security_report_url :string(191)
#  www_url             :string(191)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  keybase_id          :string(191)
#
# Indexes
#
#  index_validators_on_network_and_account  (network,account) UNIQUE
#
class Validator < ApplicationRecord
  FIELDS_FOR_API = %i[
    account
    admin_warning
    avatar_url
    created_at
    details
    id
    keybase_id
    name
    network
    updated_at
    www_url
  ].freeze

  has_many :vote_accounts, dependent: :destroy
  has_many :vote_account_histories, through: :vote_accounts, dependent: :destroy
  has_many :validator_ips, dependent: :destroy
  has_many :validator_block_histories, dependent: :destroy
  has_many :commission_histories, dependent: :destroy
  has_many :validator_histories, primary_key: :account, foreign_key: :account
  has_one :validator_ip_active, -> { active }, class_name: "ValidatorIp"
  has_one :data_center, through: :validator_ip_active
  has_one :data_center_host, through: :validator_ip_active
  has_one :validator_score_v1, dependent: :destroy
  has_one :most_recent_epoch_credits_by_account, -> {
    merge(ValidatorHistory.most_recent_epoch_credits_by_account)
  }, primary_key: :account, foreign_key: :account, class_name: 'ValidatorHistory'

  # API
  has_many :vote_accounts_for_api, -> { for_api }, class_name: "VoteAccount"
  has_one :validator_ip_active_for_api, -> { active_for_api }, class_name: "ValidatorIp"
  has_one :data_center_host_for_api, through: :validator_ip_active_for_api
  has_one :data_center_for_api, through: :data_center_host_for_api
  has_one :validator_score_v1_for_api, -> { for_api }, class_name: "ValidatorScoreV1"


  scope :active, -> { where(is_active: true, is_destroyed: false) }
  scope :scorable, -> { where(is_active: true, is_rpc: false, is_destroyed: false) }

  delegate :data_center_key, to: :data_center_host, prefix: :dch, allow_nil: true
  delegate :address, to: :validator_ip_active, prefix: :vip, allow_nil: true

  def self.with_private(show: "true")
    show == "true" ? all : where.not("validator_score_v1s.commission = 100")
  end

  def self.filtered_by(filter)
    case filter
    when :delinquent
      joins(:validator_score_v1)
        .where("validator_score_v1s.delinquent = ?", true)
    when :inactive
      where(is_active: false)
    when :private
      joins(:validator_score_v1)
        .where("validator_score_v1s.commission = ? AND validator_score_v1s.network = ?", 100, "mainnet")
    else
      all
    end
  end
  
  class << self
    # Returns an Array of account IDs for a given network
    #
    # Validator.accounts_for('testnet') => ['1234', '5678']
    def accounts_for(network)
      where(network: network).select('account').map(&:account)
    end

    # summarised active stake for all validators in the given network
    def total_active_stake_for(network)
      where(network: network).joins(:validator_score_v1).sum(:active_stake)
    end

    def index_order(order_param)
      sort_order = case order_param
                   when 'score'
                     'validator_score_v1s.total_score desc, RAND()'
                   when 'name'
                     'validators.name asc'
                   when 'stake'
                     'validator_score_v1s.active_stake desc'
                   when 'random'
                     'RAND()'
                   else
                     'validator_score_v1s.total_score desc, RAND()'
                   end

      joins(:validator_score_v1).order(sort_order)
    end

    def total_active_stake
      includes(:validator_score_v1).sum(:active_stake)
    end
  end

  def active?
    is_active
  end

  def scorable?
    is_active && !is_rpc && !is_destroyed
  end

  def validator_history_last
    ValidatorHistory.where(
      network: network,
      account: account
    ).last
  end

  # Return the vote account that was most recently used
  def vote_account_last
    vote_accounts.order('updated_at asc').last
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
    validator_ip_active&.address
  end

  def copy_data_to_score
    return unless validator_score_v1

    validator_score_v1.ip_address = ip_address
    validator_score_v1.data_center_key = dch_data_center_key if data_center
    validator_score_v1.save
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

  def data_center_concentration
    score&.data_center_concentration || 0.0
  end

  def data_center_concentration_score
    score&.data_center_concentration_score || 0
  end

  def authorized_withdrawer_score
    score&.authorized_withdrawer_score
  end

  def private_validator?
    score&.commission == 100 && network == 'mainnet'
  end

  def lido?
    name&.start_with?('Lido')
  end

  def api_url
    Rails.application.routes.url_helpers.api_v1_validator_url(
      network: self.network,
      account: self.account
    )
  end

  def to_builder
    Jbuilder.new do |validator|
      validator.(
        self,
        :network,
        :account,
        :name,
        :keybase_id,
        :www_url,
        :details,
        :avatar_url,
        :created_at,
        :updated_at,
        :admin_warning
      )
    end
  end
end
