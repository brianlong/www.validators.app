# frozen_string_literal: true

# Holds the history of getVoteAccounts RPC requests. See
# https://docs.solana.com/apps/jsonrpc-api#getvoteaccounts

# == Schema Information
#
# Table name: vote_account_histories
#
#  id                                  :bigint           not null, primary key
#  activated_stake                     :bigint
#  batch_uuid                          :string(191)
#  commission                          :integer
#  credits                             :bigint
#  credits_current                     :bigint
#  last_vote                           :bigint
#  network                             :string(191)
#  root_slot                           :bigint
#  skipped_vote_percent_moving_average :decimal(10, 4)
#  slot_index_current                  :integer
#  software_client                     :string(191)
#  software_version                    :string(191)
#  vote_latency_average                :float(24)
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  software_client_id                  :integer
#  vote_account_id                     :bigint           not null
#
# Indexes
#
#  index_vote_account_histories_on_network_and_batch_uuid          (network,batch_uuid)
#  index_vote_account_histories_on_vote_account_id                 (vote_account_id)
#  index_vote_account_histories_on_vote_account_id_and_created_at  (vote_account_id,created_at)
#
# Foreign Keys
#
#  fk_rails_...  (vote_account_id => vote_accounts.id)
#
class VoteAccountHistory < ApplicationRecord
  belongs_to :vote_account

  scope :for_batch, ->(network, batch_uuid) { where(network: network, batch_uuid: batch_uuid) }

  after_create :set_skipped_vote_percent_moving_average

  def previous_24_hours
    self.class.where(vote_account: vote_account, network: network, created_at: 24.hours.ago..created_at)
  end

  def skipped_vote_percent
    if slot_index_current.to_f.positive?
      if network == "pythnet"
        max_credits = slot_index_current
      else
        max_credits = slot_index_current * 8 + (slot_index_current - 1) * 8
      end
      return ((max_credits - (credits_current.to_i))/max_credits.to_f)
    end

    0
  end

  private

  def set_skipped_vote_percent_moving_average
    previous_24_hours_set = previous_24_hours.to_a
    skipped_vote_percent_average =
      previous_24_hours_set.map(&:skipped_vote_percent).average

    self.skipped_vote_percent_moving_average = skipped_vote_percent_average

    save if skipped_vote_percent_average
  end
end
