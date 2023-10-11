# frozen_string_literal: true

module StakeAccountsControllerHelper
  def get_explorer_stake_accounts(params:)
    @explorer_stake_accounts = ExplorerStakeAccountQuery.new(
      vote_account: params[:vote_account],
      withdrawer: params[:withdrawer],
      staker: params[:staker],
      stake_pubkey: params[:stake_pubkey], 
      network: params[:network]
    ).call(page: params[:page], per: params[:per_page])

    @stake_accounts = StakeAccount.where(
      stake_pubkey: @explorer_stake_accounts[:explorer_stake_accounts].pluck(:stake_pubkey)
    )
    [@explorer_stake_accounts, @stake_accounts]
  end
end
