# frozen_string_literal: true

# VoteAccount
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
