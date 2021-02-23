# frozen_string_literal: true

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
# Holds the history of getVoteAccounts RPC requests. See
# https://docs.solana.com/apps/jsonrpc-api#getvoteaccounts
class VoteAccountHistory < ApplicationRecord
  belongs_to :vote_account
end
