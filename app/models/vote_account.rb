# frozen_string_literal: true

# == Schema Information
#
# Table name: vote_accounts
#
#  id                    :bigint           not null, primary key
#  account               :string(191)
#  authorized_voters     :text(65535)
#  authorized_withdrawer :string(191)
#  is_active             :boolean          default(TRUE)
#  network               :string(191)
#  validator_identity    :string(191)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  validator_id          :bigint           not null
#
# Indexes
#
#  index_vote_accounts_on_account_and_created_at    (account,created_at)
#  index_vote_accounts_on_network_and_account       (network,account)
#  index_vote_accounts_on_validator_id_and_account  (validator_id,account) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (validator_id => validators.id)
#

class VoteAccount < ApplicationRecord
  FIELDS_FOR_API = %i[
    account
    id
    validator_id
  ].freeze

  belongs_to :validator
  has_many :vote_account_histories
  has_many :account_authority_histories, dependent: :destroy
  before_save :set_network
  after_save do
    if saved_change_to_authorized_withdrawer? || authorized_voters_value_changed?
      create_account_authority_history
    end
    if saved_change_to_authorized_withdrawer? || authorized_voters_value_changed? || saved_change_to_validator_identity?
      check_group_assignment
    end
  end

  serialize :authorized_voters, JSON

  scope :for_api, -> { select(FIELDS_FOR_API).order(updated_at: :asc) }
  scope :active, -> { where(is_active: true) }

  def set_inactive_without_touch
    self.is_active = false
    self.save(touch: false)
  end

  def to_builder
    Jbuilder.new do |va|
      va.vote_account self.account
    end
  end

  private

  def set_network
    self.network = validator.network if validator && network.blank?
  end

  def authorized_voters_value_changed?
    return unless saved_change_to_authorized_voters?

    changes = Array(saved_changes[:authorized_voters]).compact.map(&:values)

    # create
    return true if changes.size == 1

    before_changes, after_changes = changes.first, changes.last
    before_changes.sort != after_changes.sort
  end

  def check_group_assignment
    CheckGroupValidatorAssignmentWorker.perform_async({
      "vote_account_id" => self.id
    })
  end

  def create_account_authority_history
    account_authority_histories.create(
      authorized_withdrawer_before: authorized_withdrawer_before_last_save,
      authorized_withdrawer_after: authorized_withdrawer,
      authorized_voters_before: authorized_voters_before_last_save,
      authorized_voters_after: authorized_voters,
      network: network
    )
  end
end
