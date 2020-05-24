# frozen_string_literal: true

# VoteAccount
class VoteAccount < ApplicationRecord
  belongs_to :validator
  has_many :vote_account_histories
end
