# frozen_string_literal: true

class ExplorerStakeAccountQuery
  MIN_ACCOUNTS_NUMBER = Rails.env.test? ? 1 : 500_000

  def initialize(withdrawer: nil, staker: nil, vote_account: nil, stake_pubkey: nil, network: "mainnet", limit_count: nil)
    @withdrawer = withdrawer
    @staker = staker
    @vote_account = vote_account
    @stake_pubkey = stake_pubkey
    @network = network
    @limit_count = limit_count
  end

  def call(page: 1, per: 20)
    current_epoch = EpochWallClock.by_network(@network).first&.epoch

    explorer_stake_accounts = ExplorerStakeAccount.where(
      network: @network,
      epoch: current_epoch
    )

    if current_epoch && explorer_stake_accounts.count < MIN_ACCOUNTS_NUMBER
      explorer_stake_accounts = ExplorerStakeAccount.where(
        network: @network,
        epoch: current_epoch - 1
      )
    end

    explorer_stake_accounts = explorer_stake_accounts.where("withdrawer LIKE ?", @withdrawer) \
      if @withdrawer.present?
    explorer_stake_accounts = explorer_stake_accounts.where("staker LIKE ?", @staker) \
      if @staker.present?
    explorer_stake_accounts = explorer_stake_accounts.where("delegated_vote_account_address LIKE ?", @vote_account) \
      if @vote_account.present?
    explorer_stake_accounts = explorer_stake_accounts.where("stake_pubkey LIKE ?", @stake_pubkey) \
      if @stake_pubkey.present?

    explorer_stake_accounts = explorer_stake_accounts.order(delegated_stake: :desc)

    if @limit_count
      total = @limit_count
      explorer_stake_accounts = Kaminari.paginate_array(explorer_stake_accounts.limit(@limit_count))
    else
      total = explorer_stake_accounts.count
    end

    {
      explorer_stake_accounts: explorer_stake_accounts.page(page).per(per),
      total_count: total
    }
  end
end
