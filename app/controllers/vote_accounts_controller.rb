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

    @explorer_stake_accounts = ExplorerStakeAccount.where(
      delegated_vote_account_address: @vote_account.account,
      network: params[:network]
    ).order(delegated_stake: :desc)

    @explorer_stake_accounts = @explorer_stake_accounts.where("withdrawer LIKE ?", params[:withdrawer]) \
      if params[:withdrawer].present?
    @explorer_stake_accounts = @explorer_stake_accounts.where("staker LIKE ?", params[:staker]) \
      if params[:staker].present?
    @explorer_stake_accounts = @explorer_stake_accounts.where("stake_pubkey LIKE ?", params[:stake_pubkey]) \
      if params[:stake_pubkey].present?

    @explorer_stake_accounts_total = @explorer_stake_accounts.count

    @explorer_stake_accounts = @explorer_stake_accounts.page(params[:page] || 1).per(params[:per_page] || 30)
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
