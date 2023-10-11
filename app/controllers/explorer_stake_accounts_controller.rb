#frozen_string_literal: true

class ExplorerStakeAccountsController < ApplicationController
  include StakeAccountsControllerHelper

  def index
    if index_params[:staker] || index_params[:withdrawer] || index_params[:vote_account] || index_params[:stake_pubkey]
      @explorer_stake_accounts, @stake_accounts = get_explorer_stake_accounts(params: index_params)
      @explorer_stake_accounts = @explorer_stake_accounts[:explorer_stake_accounts]
    end
  end

  private

  def index_params
    params.permit(:staker, :withdrawer, :vote_account, :stake_pubkey, :network, :per, :page)
  end
end
