# frozen_string_literal: true

# VoteAccount
class VoteAccount < ApplicationRecord
  belongs_to :validator
  has_many :vote_account_histories

  def vote_account_history_last
    vote_account_histories.last
  end
end
