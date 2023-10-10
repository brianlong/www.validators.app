#frozen_string_literal: true

class ExplorerStakeAccountsController < ApplicationController
  def index
    if index_params[:staker] || index_params[:withdrawer] || index_params[:vote_account] || index_params[:stake_pubkey]
      @explorer_stake_accounts = ExplorerStakeAccountQuery.new(
        vote_account: index_params[:vote_account],
        withdrawer: index_params[:withdrawer],
        staker: index_params[:staker],
        stake_pubkey: index_params[:stake_pubkey], 
        network: index_params[:network]
      ).call(page: index_params[:page], per: index_params[:per_page])

      @explorer_stake_accounts_total = @explorer_stake_accounts[:total_count].to_i

      @explorer_stake_accounts = @explorer_stake_accounts[:explorer_stake_accounts]
      @stake_accounts = StakeAccount.where(stake_pubkey: @explorer_stake_accounts.pluck(:stake_pubkey))
    else
      @explorer_stake_accounts = nil
    end
  end

  private

  def index_params
    params.permit(:staker, :withdrawer, :vote_account, :stake_pubkey, :network, :per, :page)
  end
end
