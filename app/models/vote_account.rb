# frozen_string_literal: true

# == Schema Information
#
# Table name: vote_accounts
#
#  id           :bigint           not null, primary key
#  validator_id :bigint           not null
#  account      :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# VoteAccount
class VoteAccount < ApplicationRecord
  belongs_to :validator
  has_many :vote_account_histories

  def vote_account_history_last
    vote_account_histories.last
  end
end
