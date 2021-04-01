# frozen_string_literal: true

# Holds the history of getVoteAccounts RPC requests. See
# https://docs.solana.com/apps/jsonrpc-api#getvoteaccounts

# == Schema Information
#
# Table name: vote_account_histories
#
#  id                 :bigint           not null, primary key
#  activated_stake    :bigint
#  batch_uuid         :string(255)
#  commission         :integer
#  credits            :bigint
#  credits_current    :bigint
#  last_vote          :bigint
#  network            :string(255)
#  root_slot          :bigint
#  slot_index_current :integer
#  software_version   :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  vote_account_id    :bigint           not null
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
end
