# SolanaStakeAccount represents a StakeAccount on the Solana blockchain
#
# Attributes:
#
# :account_balance,
# :activating_stake,
# :activation_epoch,
# :active_stake,
# :address,
# :credits_observed,
# :deactivation_epoch,
# :delegated_stake,
# :delegated_vote_account_address,
# :epoch,
# :epoch_rewards,
# :error,
# :lockup_custodian,
# :lockup_timestamp,
# :rent_exempt_reserve,
# :stake_authority,
# :stake_type,
# :undelegated,
# :withdraw_authority

module Solana
  # include SolanaLogic

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
                  :undelegated,
                  :withdraw_authority

    def initialize(args)
      @address = args[:address]
      @rpc_urls = args[:rpc_urls]
    end

    # Parses the output from the Solana CLI and populates the attributes
    def get
      ssa = cli_request("stake-account #{@address}", @rpc_urls)
        @account_balance = ssa['accountBalance']
        @activation_epoch = ssa['activationEpoch']
        @active_stake = ssa['activeStake']
        @credits_observed = ssa['creditsObserved']
        @deactivation_epoch = ssa['deactivationEpoch']
        @delegated_stake = ssa['delegatedStake']
        @delegated_vote_account_address = ssa['delegatedVoteAccountAddress']
        @epoch_rewards = ssa['epochRewards']
        @epoch = ssa['epoch']
        @lockup_custodian = ssa['custodian']
        @lockup_timestamp = ssa['unixTimestamp']
        @rent_exempt_reserve = ssa['rentExemptReserve']
        @stake_authority = ssa['staker']
        @stake_type = ssa['stakeType']
        @withdraw_authority = ssa['withdrawer']
    rescue StandardError => e
      @error = e
    end
    
    def is_valid?
      @error.nil?
    end
  end
end
