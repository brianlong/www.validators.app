# frozen_string_literal: true

# == Schema Information
#
# Table name: vote_accounts
#
#  id                    :bigint           not null, primary key
#  account               :string(191)
#  authorized_withdrawer :string(191)
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
#  index_vote_accounts_on_validator_id              (validator_id)
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
  before_save :set_network

  scope :for_api, -> { select(FIELDS_FOR_API) }

  def vote_account_history_last
    vote_account_histories.last
  end

  def vote_account_history_for(batch_uuid)
    vote_account_histories.find_by(batch_uuid: batch_uuid)
  end

  def set_network
    self.network = validator.network if validator && network.blank?
  end

  def to_builder
    Jbuilder.new do |va|
      va.vote_account self.account
    end
  end
end
