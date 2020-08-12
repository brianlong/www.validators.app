# frozen_string_literal: true

# Validator
class Validator < ApplicationRecord
  has_many :vote_accounts
  has_many :vote_account_histories, through: :vote_accounts
  has_many :validator_ips
  has_many :validator_block_histories
  has_one :validator_score_v1

  # Returns an Array of account IDs for a given network
  #
  # Validator.accounts_for('testnet') => ['1234', '5678']
  def self.accounts_for(network)
    where(network: network)
      .select('account')
      .map(&:account)
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
end
