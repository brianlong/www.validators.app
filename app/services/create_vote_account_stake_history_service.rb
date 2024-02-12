# frozen_string_literal: true

class CreateVoteAccountStakeHistoryService
  def initialize(network: "mainnet", epoch:)
    @network = network
    @epoch = epoch
  end

  def call
    active_vote_accounts.each do |vote_account|
      stake_accounts = ExplorerStakeAccount.where(
        delegated_vote_account_address: vote_account.account,
        network: @network
      )
      vash = VoteAccountStakeHistory.find_or_initialize_by(epoch: @epoch, vote_account: vote_account, network: @network)

      vash.account_balance = stake_accounts.sum(:account_balance)
      vash.active_stake = stake_accounts.sum(:active_stake)
      vash.credits_observed = stake_accounts.sum(:credits_observed)
      vash.deactivating_stake = stake_accounts.sum(:deactivating_stake)
      vash.delegated_stake = stake_accounts.sum(:delegated_stake)
      vash.rent_exempt_reserve = stake_accounts.sum(:rent_exempt_reserve)
      vash.delegating_stake_accounts_count = stake_accounts.count

      vash.save
    end
  end

  def active_vote_accounts
    @active_vote_accounts ||= VoteAccount.where(network: @network, is_active: true)
  end
end
