# frozen_string_literal: true

class ExplorerStakeAccountQuery
  MIN_ACCOUNTS_NUMBER = Rails.env.test? ? 1 : 500_000

  def initialize(withdrawer: nil, staker: nil, vote_account: nil, stake_pubkey: nil, network: "mainnet")
    @withdrawer = withdrawer
    @staker = staker
    @vote_account = vote_account
    @stake_pubkey = stake_pubkey
    @network = network
  end

  def call(page: 1, per: 20)
    explorer_stake_accounts = ExplorerStakeAccount.where(
      network: @network,
      epoch: EpochWallClock.by_network(@network).last&.epoch
    )

    if explorer_stake_accounts.count < MIN_ACCOUNTS_NUMBER
      explorer_stake_accounts = ExplorerStakeAccount.where(
        network: @network,
        epoch: EpochWallClock.by_network(@network).last&.epoch - 1
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

    total = explorer_stake_accounts.count

    {
      explorer_stake_accounts: explorer_stake_accounts.order(delegated_stake: :desc).page(page).per(per),
      total_count: total
    }
  end
end
