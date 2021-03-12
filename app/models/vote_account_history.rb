# frozen_string_literal: true

# Holds the history of getVoteAccounts RPC requests. See
# https://docs.solana.com/apps/jsonrpc-api#getvoteaccounts

# == Schema Information
#
# Table name: vote_account_histories
#
#  id                 :bigint           not null, primary key
#  vote_account_id    :bigint           not null
#  commission         :integer
#  last_vote          :bigint
#  root_slot          :bigint
#  credits            :bigint
#  activated_stake    :bigint
#  software_version   :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  network            :string(255)
#  batch_uuid         :string(255)
#  credits_current    :bigint
#  slot_index_current :integer
#
# Indexes
#
#  index_vote_account_histories_on_network_and_batch_uuid          (network,batch_uuid)
#  index_vote_account_histories_on_vote_account_id                 (vote_account_id)
#  index_vote_account_histories_on_vote_account_id_and_created_at  (vote_account_id,created_at)
#
class VoteAccountHistory < ApplicationRecord
  belongs_to :vote_account
end
