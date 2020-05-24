# frozen_string_literal: true

# Validator
class Validator < ApplicationRecord
  has_many :vote_accounts
  has_many :validator_ips
end
