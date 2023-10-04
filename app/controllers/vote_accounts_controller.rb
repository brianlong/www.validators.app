# frozen_string_literal: true

class VoteAccountsController < ApplicationController
  before_action :set_validator, only: %i[show]
  before_action :set_vote_account, only: %i[show]

  def show
    time_from = Time.now - 24.hours
    time_to = Time.now

    @vote_account_histories = @vote_account.vote_account_histories
                                           .where("created_at BETWEEN ? AND ?", time_from, time_to)
                                           .order(id: :desc)
                                           .limit(60)

    @explorer_stake_accounts = ExplorerStakeAccountQuery.new(
      staker: "test_staker_2",
      withdrawer: "test_withdrawer_2",
      network: @network,
    ).call(page: params[:page], per: params[:per_page])

    @explorer_stake_accounts_total = @explorer_stake_accounts[:total_count]

    @explorer_stake_accounts = @explorer_stake_accounts[:explorer_stake_accounts]
    @stake_accounts = StakeAccount.where(stake_pubkey: @explorer_stake_accounts.pluck(:stake_pubkey))

  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_vote_account
    @vote_account = VoteAccount.where(
      network: params[:network],
      account: params[:vote_account],
      validator_id: @validator&.id
    ).last

    render file: "#{Rails.root}/public/404.html", layout: nil, status: 404 if @vote_account.nil?
  end

  def set_validator
    @validator = Validator.find_by(network: params[:network], account: params[:account])
  end
end
