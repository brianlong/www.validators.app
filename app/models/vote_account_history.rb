# frozen_string_literal: true

# Holds the history of getVoteAccounts RPC requests. See
# https://docs.solana.com/apps/jsonrpc-api#getvoteaccounts
class VoteAccountHistory < ApplicationRecord
  belongs_to :vote_account
end
