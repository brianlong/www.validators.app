# frozen_string_literal: true

# Holds the history of getVoteAccounts RPC requests. See
# https://docs.solana.com/apps/jsonrpc-api#getvoteaccounts

# == Schema Information
#
# Table name: vote_account_histories
#
#  id                                   :bigint           not null, primary key
#  vote_account_id                      :bigint           not null
#  commission                           :integer
#  last_vote                            :bigint
#  root_slot                            :bigint
#  credits                              :bigint
#  activated_stake                      :bigint
#  software_version                     :string(255)
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#  network                              :string(255)
#  batch_uuid                           :string(255)
#  credits_current                      :bigint
#  slot_index_current                   :integer
#  skipped_vote_percent_moving_average  :decimal
#
# Indexes
#
#  index_vote_account_histories_on_network_and_batch_uuid          (network,batch_uuid)
#  index_vote_account_histories_on_vote_account_id                 (vote_account_id)
#  index_vote_account_histories_on_vote_account_id_and_created_at  (vote_account_id,created_at)
#
class VoteAccountHistory < ApplicationRecord
  belongs_to :vote_account

  after_create :set_skipped_vote_percent_moving_average

  def previous_24_hours
    self.class.where(vote_account: vote_account, network: network, created_at: 24.hours.ago..created_at)
  end

  def skipped_vote_percent
    ((slot_index_current.to_i - credits_current.to_i)/slot_index_current.to_f).round(2)
  end

  def set_skipped_vote_percent_moving_average
    previous_24_hours_set = self.previous_24_hours.to_a
    self.skipped_vote_percent_moving_average = previous_24_hours_set.map(&:skipped_vote_percent).sum/previous_24_hours_set.count
    save
  end

  def self.average_skipped_vote_percent_for(network:, batch_uuid:)
    vah_skipped = where(
      network: network,
      batch_uuid: batch_uuid
    ).map(&:skipped_vote_percent)
    vah_skipped.sum / vah_skipped.count
  end

  def self.median_skipped_vote_percent_for(network:, batch_uuid:)
    vah_skipped = where(
      network: network,
      batch_uuid: batch_uuid
    ).map(&:skipped_vote_percent)
    vah_skipped.sort[vah_skipped.length/2]
  end

  def self.average_skipped_vote_percent_moving_average_for(network:, batch_uuid:)
    where(
      network: network,
      batch_uuid: batch_uuid
    ).average(:skipped_vote_percent_moving_average)
  end

  def self.median_skipped_vote_percent_moving_average_for(network:, batch_uuid:)
    where(
      network: network,
      batch_uuid: batch_uuid
    ).median(:skipped_vote_percent_moving_average)
  end
end
