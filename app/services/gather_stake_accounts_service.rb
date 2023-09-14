# frozen_string_literal: true

class GatherStakeAccountsService
  include PipelineLogic
  include SolanaRequestsLogic

  def initialize(network: "mainnet", config_urls:, current_epoch:, demo: true)
    @network = network
    @config_urls = config_urls
    @stake_accounts = []
    @current_epoch = current_epoch
    @demo = demo
  end

  def call
    get_stake_accounts
    update_stake_accounts
    puts "finished"
  end

  private

  def get_stake_accounts
    @stake_accounts = cli_request(
      'stakes',
      @config_urls
    )
  end

  def update_stake_accounts
    @stake_accounts.in_groups_of(10_000) do |batch|
      updated_stake_accounts = []

      batch.each_with_index do |acc, index|
        puts "#{index} of #{batch.count}"

        next unless acc

        esa = ExplorerStakeAccount.find_or_initialize_by(
          stake_pubkey: acc['stakePubkey'],
          network: @network
        )

        esa.assign_attributes(
          account_balance: acc['accountBalance'],
          activation_epoch: acc['activationEpoch'],
          active_stake: acc['activeStake'],
          credits_observed: acc['creditsObserved'],
          deactivating_stake: acc['deactivatingStake'],
          deactivation_epoch: acc['deactivationEpoch'],
          delegated_stake: acc['delegatedStake'],
          delegated_vote_account_address: acc['delegatedVoteAccountAddress'],
          rent_exempt_reserve: acc['rentExemptReserve'],
          stake_pubkey: acc['stakePubkey'],
          stake_type: acc['stakeType'],
          staker: acc['staker'],
          withdrawer: acc['withdrawer']
        )

        updated_stake_accounts << esa
      end
      save_stake_accounts(updated_stake_accounts)
    end
  end

  def save_stake_accounts(esa_batch)
    esa_batch.each(&:save!) unless @demo
  end
end
