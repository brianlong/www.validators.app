# frozen_string_literal: true

# Validator
class Validator < ApplicationRecord
  has_many :vote_accounts
  has_many :vote_account_histories, through: :vote_accounts
  has_many :validator_ips
  has_many :validator_block_histories

  # Returns an Array of account IDs for a given network
  #
  # Validator.accounts_for('testnet') => ['1234', '5678']
  def self.accounts_for(network)
    where(network: network)
      .select('account')
      .map(&:account)
  end
end
