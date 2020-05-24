# frozen_string_literal: true

# Validator
class Validator < ApplicationRecord
  has_many :vote_accounts
  has_many :vote_account_histories, through: :vote_accounts
  has_many :validator_ips
  has_many :validator_block_histories
end
