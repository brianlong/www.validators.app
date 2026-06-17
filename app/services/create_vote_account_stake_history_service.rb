# frozen_string_literal: true

class CreateVoteAccountStakeHistoryService
  def initialize(network: "mainnet", epoch:)
    @network = network
    @epoch = epoch
  end

  def call
    aggregates_by_address = ExplorerStakeAccount
      .where(network: @network, epoch: @epoch,
             delegated_vote_account_address: active_vote_accounts.map(&:account))
      .group(:delegated_vote_account_address)
      .select(
        :delegated_vote_account_address,
        "SUM(account_balance) AS sum_account_balance",
        "SUM(active_stake) AS sum_active_stake",
        "AVG(active_stake) AS avg_active_stake",
        "SUM(credits_observed) AS sum_credits_observed",
        "SUM(deactivating_stake) AS sum_deactivating_stake",
        "SUM(delegated_stake) AS sum_delegated_stake",
        "SUM(rent_exempt_reserve) AS sum_rent_exempt_reserve",
        "COUNT(*) AS stake_accounts_count"
      )
      .index_by(&:delegated_vote_account_address)

    active_vote_accounts.each do |vote_account|
      agg = aggregates_by_address[vote_account.account]
      next unless agg

      vash = VoteAccountStakeHistory.find_or_initialize_by(epoch: @epoch, vote_account: vote_account, network: @network)

      vash.account_balance = agg.sum_account_balance
      vash.active_stake = agg.sum_active_stake
      vash.average_active_stake = agg.avg_active_stake
      vash.credits_observed = agg.sum_credits_observed
      vash.deactivating_stake = agg.sum_deactivating_stake
      vash.delegated_stake = agg.sum_delegated_stake
      vash.rent_exempt_reserve = agg.sum_rent_exempt_reserve
      vash.delegating_stake_accounts_count = agg.stake_accounts_count

      vash.save
    end

    create_explorer_stake_account_history_stat
  end

  def active_vote_accounts
    @active_vote_accounts ||= VoteAccount.where(network: @network, is_active: true)
  end

  def create_explorer_stake_account_history_stat
    agg = ExplorerStakeAccount
      .where(network: @network, epoch: @epoch)
      .select(
        "SUM(account_balance) AS sum_account_balance",
        "SUM(active_stake) AS sum_active_stake",
        "AVG(active_stake) AS avg_active_stake",
        "SUM(credits_observed) AS sum_credits_observed",
        "SUM(deactivating_stake) AS sum_deactivating_stake",
        "SUM(delegated_stake) AS sum_delegated_stake",
        "SUM(rent_exempt_reserve) AS sum_rent_exempt_reserve",
        "COUNT(*) AS stake_accounts_count"
      )
      .first

    ExplorerStakeAccountHistoryStat.create(
      epoch: @epoch,
      network: @network,
      account_balance: agg.sum_account_balance,
      active_stake: agg.sum_active_stake,
      average_active_stake: agg.avg_active_stake,
      credits_observed: agg.sum_credits_observed,
      deactivating_stake: agg.sum_deactivating_stake,
      delegated_stake: agg.sum_delegated_stake,
      rent_exempt_reserve: agg.sum_rent_exempt_reserve,
      delegating_stake_accounts_count: agg.stake_accounts_count
    )
  end
end
