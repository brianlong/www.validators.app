# frozen_string_literal: true

# SolanaStakeAccount represents a StakeAccount on the Solana blockchain
#
# Attributes
# account_balance: The total balance of the stake account
# activating_stake: The amount of stake that is still warming up
# activation_epoch: The epoch when this stake is/was active
# active_stake: The amount of active stake
# address: The on-chain address for this stake account
# credits_observed: Vote credits attributed to this stake
# deactivation_epoch: The epoch when this stake was deactivated. Default: nil
# delegated_stake: The amount of stake delegated to the validator
# delegated_vote_account_address: The validator's vote account
# epoch: current epoch
# epoch_rewards: rewards this epoch
# error: An error object. Default: nil
# lockup_custodian: The address of the lock-up custodian, if any.
# lockup_timestamp: The unix timestamp indicating when the lockup ends, if any.
# rent_exempt_reserve: The reserve required to be rent exempt
# stake_authority: The address holding the stake authority
# stake_type: The tupe of stake. Default 'Stake'
# withdraw_authority: the address with the authority to deactivate, withdraw,
#                     or change the stake authority.
#
# Sample Use:
#   stake_account = Solana::StakeAccount.new(
#                     address: address,
#                     rpc_urls: TESTNET_CLUSTER_URLS
#                   )
#   stake_account.get => Will fetch the account details from the blockchain
module Solana
  class StakeAccount
    include SolanaLogic

    attr_accessor :account_balance,
                  :activating_stake,
                  :activation_epoch,
                  :active_stake,
                  :address,
                  :credits_observed,
                  :deactivation_epoch,
                  :delegated_stake,
                  :delegated_vote_account_address,
                  :epoch,
                  :epoch_rewards,
                  :error,
                  :lockup_custodian,
                  :lockup_timestamp,
                  :rent_exempt_reserve,
                  :stake_authority,
                  :stake_type,
                  :withdraw_authority,
                  :cli_error

    def initialize(args)
      @address = args[:address]
      @rpc_urls = args[:rpc_urls]
    end

    # Gets the output from the Solana CLI and populates the attributes
    def get
      ssa = cli_request("stake-account #{@address}", @rpc_urls)
      ssa_resp = ssa['cli_response']
      @cli_error = ssa['cli_error']
      @account_balance = ssa_resp['accountBalance']
      @activation_epoch = ssa_resp['activationEpoch']
      @active_stake = ssa_resp['activeStake']
      @credits_observed = ssa_resp['creditsObserved']
      @deactivation_epoch = ssa_resp['deactivationEpoch']
      @delegated_stake = ssa_resp['delegatedStake']
      @delegated_vote_account_address = ssa_resp['delegatedVoteAccountAddress']
      @epoch_rewards = ssa_resp['epochRewards']
      @epoch = ssa_resp['epoch']
      @lockup_custodian = ssa_resp['custodian']
      @lockup_timestamp = ssa_resp['unixTimestamp']
      @rent_exempt_reserve = ssa_resp['rentExemptReserve']
      @stake_authority = ssa_resp['staker']
      @stake_type = ssa_resp['stakeType']
      @withdraw_authority = ssa_resp['withdrawer']
    rescue StandardError => e
      @error = e
    end

    def valid?
      @error.nil?
    end

    def active?
      @error.nil? && @deactivation_epoch.nil?
    end
  end
end
