# frozen_string_literal: true

# == Schema Information
#
# Table name: vote_accounts
#
#  id           :bigint           not null, primary key
#  validator_id :bigint           not null
#  account      :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  network      :string(255)
#
# Indexes
#
#  index_vote_accounts_on_account_and_created_at    (account,created_at)
#  index_vote_accounts_on_network_and_account       (network,account)
#  index_vote_accounts_on_validator_id              (validator_id)
#  index_vote_accounts_on_validator_id_and_account  (validator_id,account) UNIQUE
#

class VoteAccount < ApplicationRecord
  belongs_to :validator
  has_many :vote_account_histories
  before_save :set_network

  def vote_account_history_last
    vote_account_histories.last
  end

  def set_network
    self.network = validator.network if validator && network.blank?
  end
end
