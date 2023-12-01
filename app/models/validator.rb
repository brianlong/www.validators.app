# frozen_string_literal: true

# == Schema Information
#
# Table name: validators
#
#  id                  :bigint           not null, primary key
#  account             :string(191)
#  admin_warning       :string(191)
#  avatar_hash         :string(191)
#  avatar_url          :string(191)
#  consensus_mods      :boolean          default(FALSE)
#  details             :string(191)
#  info_pub_key        :string(191)
#  is_active           :boolean          default(TRUE)
#  is_destroyed        :boolean          default(FALSE)
#  is_rpc              :boolean          default(FALSE)
#  jito                :boolean          default(FALSE)
#  jito_commission     :integer
#  name                :string(191)
#  network             :string(191)
#  security_report_url :string(191)
#  stake_pools_list    :text(65535)
#  www_url             :string(191)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  keybase_id          :string(191)
#
# Indexes
#
#  index_validators_on_network_and_account                    (network,account) UNIQUE
#  index_validators_on_network_is_active_is_destroyed_is_rpc  (network,is_active,is_destroyed,is_rpc)
#
class Validator < ApplicationRecord

  include AvatarAttachment
  include Rails.application.routes.url_helpers

  FIELDS_FOR_API = %i[
    account
    avatar_url
    created_at
    details
    id
    keybase_id
    name
    network
    updated_at
    www_url
    admin_warning
    jito
    stake_pools_list
  ].freeze

  FIELDS_FOR_GOSSIP_NODES = FIELDS_FOR_API.reject { |f| %i[account created_at updated_at network].include? f }.freeze

  DEFAULT_FILTERS = %w(active private delinquent).freeze

  has_many :vote_accounts, dependent: :destroy
  has_many :account_authority_histories, through: :vote_accounts, dependent: :destroy
  has_many :stake_accounts, dependent: :destroy
  has_many :vote_account_histories, through: :vote_accounts, dependent: :destroy
  has_many :validator_ips, dependent: :nullify
  has_many :validator_block_histories, dependent: :destroy
  has_many :commission_histories, dependent: :destroy
  has_many :validator_histories, dependent: :nullify

  has_many :user_watchlist_elements, dependent: :destroy
  has_many :watchers, through: :user_watchlist_elements, source: :user

  has_one :validator_ip_active, -> { active }, class_name: "ValidatorIp"
  has_one :data_center, through: :validator_ip_active
  has_one :data_center_host, through: :validator_ip_active
  has_one :validator_score_v1, dependent: :destroy
  has_one :validator_score_v1_for_web, -> { for_web }, class_name: "ValidatorScoreV1"
  has_one :group_validator, dependent: :destroy
  has_one :group, through: :group_validator
  has_many :stake_accounts, dependent: :nullify

  # API
  has_many :vote_accounts_for_api, -> { for_api }, class_name: "VoteAccount"
  has_one :validator_ip_active_for_api, -> { active_for_api }, class_name: "ValidatorIp"
  has_one :data_center_host_for_api, through: :validator_ip_active_for_api
  has_one :data_center_for_api, through: :data_center_host_for_api
  has_one :validator_score_v1_for_api, -> { for_api }, class_name: "ValidatorScoreV1"

  scope :active, -> { where(is_active: true, is_destroyed: false) }
  scope :scorable, -> { where(is_active: true, is_rpc: false, is_destroyed: false) }
  scope :for_api, -> { select(FIELDS_FOR_API) }

  serialize :stake_pools_list, Array, default: []

  delegate :data_center_key, to: :data_center_host, prefix: :dch, allow_nil: true
  delegate :address, to: :validator_ip_active, prefix: :vip, allow_nil: true

  after_save :update_avatar_file, if: :saved_change_to_avatar_url?

  class << self
    def with_private(show: "true")
      show == "true" ? all : where.not("validator_score_v1s.commission = 100")
    end

    def default_filters(network)
      network == "mainnet" ? DEFAULT_FILTERS : DEFAULT_FILTERS.reject{ |v| v == "private" }
    end

    # accepts array of strings or string
    def filtered_by(filter)
      return nil if filter.blank?

      vals = all.joins(:validator_score_v1)
      query = []

      query.push "validator_score_v1s.delinquent = true" if filter.include? "delinquent"
      query.push "validators.is_active = true" if filter.include? "active"
      query.push "validator_score_v1s.commission = 100" if filter.include? "private"

      vals.where(query.join(" OR "))
    end

    # Returns an Array of account IDs for a given network
    #
    # Validator.accounts_for('testnet') => ['1234', '5678']
    def accounts_for(network)
      where(network: network).select('account').map(&:account)
    end

    # summarised active stake for all validators in the given network
    def total_active_stake_for(network)
      active.where(network: network).joins(:validator_score_v1).sum(:active_stake)
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

  def avatar_file_url
    polymorphic_url(avatar) if avatar.attached?
  end

  def update_avatar_file
    UpdateAvatarFileWorker.set(queue: :low_priority)
                          .perform_async({validator_id: id}.stringify_keys) unless avatar_url.nil?
  end

  def active?
    is_active
  end

  def scorable?
    is_active && !is_rpc && !is_destroyed
  end

  def validator_history_last
    validator_histories.last
  end

  # Return the vote account that was most recently used
  def vote_account_active
    vote_accounts.active.order('updated_at asc').last || vote_accounts.order('updated_at asc').last
  end

  def set_active_vote_account(vote_acc)
    vote_acc.update(is_active: true, updated_at: Time.now)
    vote_accounts.where.not(account: vote_acc.account).map(&:set_inactive_without_touch)
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

  def commission_histories_exist
    CommissionHistoryQuery.new(network: network)
                          .exists_for_validator?(id)
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

  def consensus_mods_score
    score&.consensus_mods_score.to_i
  end

  def private_validator?
    score&.commission == 100 && network == 'mainnet'
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
        :admin_warning,
        :jito
      )
    end
  end
end
