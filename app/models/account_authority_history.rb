# frozen_string_literal: true

# == Schema Information
#
# Table name: account_authority_histories
#
#  id                           :bigint           not null, primary key
#  authorized_voters_after      :text(65535)
#  authorized_voters_before     :text(65535)
#  authorized_withdrawer_after  :string(191)
#  authorized_withdrawer_before :string(191)
#  network                      :string(191)
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  vote_account_id              :bigint           not null
#
# Indexes
#
#  index_account_authority_histories_on_vote_account_id  (vote_account_id)
#
# Foreign Keys
#
#  fk_rails_...  (vote_account_id => vote_accounts.id)
#
class AccountAuthorityHistory < ApplicationRecord
  belongs_to :vote_account

  serialize :authorized_voters_before, JSON
  serialize :authorized_voters_after, JSON

  API_FIELDS = %i[
    authorized_voters_after
    authorized_voters_before
    authorized_withdrawer_after
    authorized_withdrawer_before
    network
    created_at
    updated_at
  ].freeze

  def vote_account_address
    vote_account.account
  end
end
