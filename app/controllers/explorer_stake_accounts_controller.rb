#frozen_string_literal: true

class ExplorerStakeAccountsController < ApplicationController
  include StakeAccountsControllerHelper

  def index
    if index_params[:staker].present? || \
      index_params[:withdrawer].present? || \
      index_params[:vote_account].present? || \
      index_params[:stake_pubkey].present?
     @explorer_stake_accounts, @stake_accounts = get_explorer_stake_accounts(params: index_params)
     @explorer_stake_accounts = @explorer_stake_accounts[:explorer_stake_accounts]
   end
  end

  private

  def index_params
    params.permit(:staker, :withdrawer, :vote_account, :stake_pubkey, :network, :per, :page)
  end
end
