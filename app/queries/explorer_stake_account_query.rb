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

  def call(page: 1, per: 20, with_count: false)
    current_epoch = EpochWallClock.by_network(@network).first&.epoch
    epoch = select_epoch(current_epoch)

    explorer_stake_accounts = ExplorerStakeAccount.where(
      network: @network,
      epoch: epoch
    ).where("active_stake > ?", 0)

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
    elsif with_count
      total = account_filter_present? ? explorer_stake_accounts.count : precomputed_count(epoch)
    end

    {
      explorer_stake_accounts: explorer_stake_accounts.page(page).per(per),
      total_count: total
    }
  end

  private

  def select_epoch(current_epoch)
    return current_epoch unless current_epoch

    stat_count = ExplorerStakeAccountHistoryStat
      .where(network: @network, epoch: current_epoch)
      .pick(:delegating_stake_accounts_count)

    return current_epoch if stat_count.nil?

    stat_count < MIN_ACCOUNTS_NUMBER ? current_epoch - 1 : current_epoch
  end

  def account_filter_present?
    @withdrawer.present? || @staker.present? || @vote_account.present? || @stake_pubkey.present?
  end

  def precomputed_count(epoch)
    ExplorerStakeAccountHistoryStat
      .where(network: @network, epoch: epoch)
      .pick(:delegating_stake_accounts_count) || 0
  end
end
