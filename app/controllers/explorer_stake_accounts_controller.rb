# frozen_string_literal: true

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

  def show  
    @explorer_stake_account = ExplorerStakeAccount.find_by(
      stake_pubkey: params[:stake_pubkey],
      network: params[:network]
    )
    @stake_account = StakeAccount.find_by(stake_pubkey: params[:stake_pubkey])
    @vote_account = VoteAccount.find_by(
      account: @explorer_stake_account.delegated_vote_account_address,
      network:params[:network]
    )
  end

  private

  def index_params
    params.permit(:staker, :withdrawer, :vote_account, :stake_pubkey, :network, :per, :page)
  end
end
