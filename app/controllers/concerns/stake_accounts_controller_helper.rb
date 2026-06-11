# frozen_string_literal: true

module StakeAccountsControllerHelper
  def get_explorer_stake_accounts(params:, limit_count: nil, with_count: false)
    @explorer_stake_accounts = ExplorerStakeAccountQuery.new(
      vote_account: params[:vote_account],
      withdrawer: params[:withdrawer],
      staker: params[:staker],
      stake_pubkey: params[:stake_pubkey],
      network: params[:network],
      limit_count: limit_count
    ).call(page: params[:page], per: params[:per], with_count: with_count)

    @stake_accounts = StakeAccount.where(
      stake_pubkey: @explorer_stake_accounts[:explorer_stake_accounts].pluck(:stake_pubkey)
    )
    [@explorer_stake_accounts, @stake_accounts]
  end
end
