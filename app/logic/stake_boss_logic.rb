# frozen_string_literal: true

# See https://www.validators.app/stake-boss for a high-level overview of the
# Stake Boss. The intial iteration will simply split a stake account indicated
# by the owner and then manage the delegation to the best validators. Future
# iterations will allow the account owner to provide a list of validators to
# include or exclude from their validator set.
#
# StakeBossLogic contains methods used for splitting and delegating stake
# accounts. Many of these methods are simple wrappers for shell and on-chain
# commands. These methods are lambdas that we can use in a processing pipeline
# for various purposes.
#
# See `config/initializers/pipeline.rb` for a description of the Pipeline struct
#
# The pipeline starts with the initial payload and then performs a series of
# steps where the output of each step is passed into the input of the next step.
#
# Example:
#
#   payload = {
#     config_urls: ['https://testnet.solana.com:8899'],
#     network: args['network'],
#     stake_address: args['stake_address']
#   }
#
# The pipeline for the first iteration to determine balance & set max_n_split
# looks like this:
#
#   _p = Pipeline.new(200, payload)
#                .then(&guard_input)
#                .then(&guard_stake_account)
#                .then(&guard_duplicate_records)
#                .then(&set_max_n_split)
#                .then(&log_errors)
#
# The pipeline for the second iteration where we split the accounts and
# delegate the validators looks like this:
#
#   payload = {
#     config_urls: ['https://testnet.solana.com:8899'],
#     network: args['network'],
#     stake_address: args['stake_address'],
#     split_n_ways: args['split_n_ways']
#   }
#
#   _p = Pipeline.new(200, payload)
#                .then(&guard_input)
#                .then(&guard_stake_account)
#                .then(&guard_duplicate_records)
#                .then(&set_max_n_split)
#                .then(&select_validators)
#                .then(&register_first_stake_account)
#                .then(&log_errors)

require 'base58'

module StakeBossLogic
  include ApplicationHelper
  include SolanaLogic

  RPC_TIMEOUT = 60 # seconds
  ILLEGAL_CHARS_REGEXP = /[+\-_,&|'"]/.freeze

  # InvalidStakeAccount is a custom Error class with a default message for
  # invalid Stake Accounts
  #
  # raise InvalidStakeAccount.new('Blank Address') creates a new Error (e):
  #   e.class: StakeBossLogic::InvalidStakeAccount
  #   e.message: 'Invalid Stake Account: Blank Address'
  class InvalidStakeAccount < StandardError
    attr_accessor :message

    def initialize(message = nil)
      super
      @message = "Invalid Stake Account: #{message}".strip
    end
  end

  # Guard against invalid or malicious input. The checks are:
  #   - No blank or null addresses
  #   - No script in the provided address
  #   - The base58 string representing the address should be between 32 and 44 bytes long
  #   - there should be no characters that do not occur in standard solana address
  def guard_input
    lambda do |p|
      return p unless p.code == 200
      # Make sure the address is not blank
      raise InvalidStakeAccount, 'Blank Address' \
        if p.payload[:stake_address].blank?

      # Make sure the address does not contain script
      raise InvalidStakeAccount, 'Hi Leo, javascript is not allowed!' \
        if p.payload[:stake_address].include?('<script')

      raise InvalidStakeAccount, 'whitespaces not allowed' \
        if p.payload[:stake_address].match(/\s/)

      raise InvalidStakeAccount, 'Address contains illegal characters' \
        if p.payload[:stake_address].match(ILLEGAL_CHARS_REGEXP)

      # Make sure the base58 decoded address is the right length (32 - 44 bytes)
      raise InvalidStakeAccount, 'Address is wrong size' \
        unless (32..44).include?(Base58.base58_to_binary(p.payload[:stake_address]).bytes.length)

      # Script encoded in base58?

      Pipeline.new(200, p.payload)
    rescue StandardError, StakeBossLogic::InvalidStakeAccount => e
      Pipeline.new(500, p.payload, 'Error from guard_input', e)
    end
  end

  # Make sure that we have a valid stake account, that we possess the
  # StakeAuthority, and the balance is > zero. We will load the account from
  # the blockchain and then:
  #   - Confirm that it is a valid Stake Account
  #   - That the Stake Boss has the Stake Authority
  #   - The Stake Account is active
  #   - The stake is > STAKE_BOSS_MIN (See config/initializers/cluster.rb)
  def guard_stake_account
    lambda do |p|
      return p unless p.code == 200
      # Load the account info from the blockchain
      stake_account = Solana::StakeAccount.new(
        address: p.payload[:stake_address],
        rpc_urls: p.payload[:config_urls]
      )
      stake_account.get
      # Is solana account but not a stake account
      if stake_account.cli_error&.include?('is not a stake account')
        raise InvalidStakeAccount, 'This is not a Stake Account'
      end

      # Make sure this is a valid stake account
      raise InvalidStakeAccount, 'Not a valid Stake Account' \
        unless stake_account.valid?

      # Make sure that we have the stake authority
      raise InvalidStakeAccount, 'Stake Boss needs Stake Authority' \
        unless stake_account.stake_authority == STAKE_BOSS_ADDRESS

      # Is the stake account currently active?
      raise InvalidStakeAccount, 'Stake Account is inactive' \
        unless stake_account.active?

      # Is the balance > 10?
      raise InvalidStakeAccount, 'Balance is too low' \
        unless lamports_to_sol(stake_account.account_balance) >= STAKE_BOSS_MIN

      # Append the valid stake account to the payload
      Pipeline.new(200, p.payload.merge(solana_stake_account: stake_account))
    rescue StandardError, StakeBossLogic::InvalidStakeAccount => e
      Pipeline.new(500, p.payload, 'Error from guard_stake_account', e)
    end
  end

  # Guard against duplicate records in the stake_boss_stake_accounts table
  def guard_duplicate_records
    lambda do |p|
      return p unless p.code == 200
      # TODO: Check for duplicates in the stake_boss_stake_accounts table
      raise InvalidStakeAccount, 'Duplicate Record' \
        if StakeBoss::StakeAccount.where(
          network: p.payload[:network],
          address: p.payload[:stake_address]
        ).first

      Pipeline.new(200, p.payload)
    rescue StandardError, StakeBossLogic::InvalidStakeAccount => e
      Pipeline.new(500, p.payload, 'Error from guard_duplicate_records', e)
    end
  end

  # We want to protect against pranksters who might try to submit a ridiculously
  # large split value (N) to cause problems or drain our transaction fee
  # account. We will calculate our own max based on the size of the stake. Then
  # `split_n_max` will be used as a sanity check for an acceptable range of
  # 2 - split_n_max.
  def set_max_n_split
    lambda do |p|
      return p unless p.code == 200
      # The default split N-ways is 2. The user can pick a value between
      # 2 and split_n_max
      split_n_ways = 2

      # Figure out the max N ways we can split this account without each
      # balance going below the minimum
      split_n_max = split_n_ways
      STAKE_BOSS_N_SPLIT_OPTIONS.each do |n|
        ds = p.payload[:solana_stake_account].delegated_stake
        break if (lamports_to_sol(ds) / n) < 5

        split_n_max = n
      end

      Pipeline.new(
        200,
        p.payload.merge(split_n_ways: 2, split_n_max: split_n_max)
      )
    rescue StandardError => e
      puts e
      Pipeline.new(500, p.payload, 'Error from register_first_stake_account', e)
    end
  end

  # NOTE: The steps above will be used to process a first request from the User.
  # After we confirm that we have a valid stake account with balance > 10
  # lamports, we will determine the max N ways to split the account and then
  # proceed to split the account and delegate to validators.
  #
  # The steps above will need to be repeated in the second step since we just
  # accepted input from the Internet. The second time, we will have the value
  # for N (default: 2)

  # This first iteration of select_validators will grab the list of validators
  # from the validator_score_v1s table, sort the results by total score in
  # descending order, and work from the top down until we have found the
  # correct number of validators for this batch.
  #
  # Future iterations will allow a logged in user to provide a list of
  # validators to include or exclude from their validator set.
  #
  # The first stake account will be delegated to BLOCK_LOGIC_VOTE_ACCOUNT. The
  # rewards that we earn should cover the cost of maintaining the service and
  # the transaction fees.
  def select_validators
    lambda do |p|
      return p unless p.code == 200
      select_fields = %i[
        id validator_id commission delinquent stake_concentration_score
        data_center_concentration_score data_center_key
      ]
      scores = ValidatorScoreV1.where(network: p.payload[:network])
                               .select(select_fields)
                               .order('total_score desc')

      # The first stake account will be delegated to BLOCK_LOGIC_VOTE_ACCOUNT
      validators = []
      scores.each do |score|
        # Reject delinquent validators
        next if score.delinquent

        # Reject validators with a stake concentration score < 0
        next if score.stake_concentration_score.negative?

        # Reject validators with commission > 10%
        next if score.commission.to_i > 10

        # This is a stub to exclude Hetzner until we change the
        # data_center_concentration_score to count only ASN. In the future,
        # any validator with ASN concentration > 25% will be rejected.
        next if score.data_center_key.include?('24940')

        validators << score.validator.vote_account_last.account
        break if validators.count == (p.payload[:split_n_ways] - 1)
      end

      Pipeline.new(200, p.payload.merge(validators: validators))
    rescue StandardError => e
      puts e
      Pipeline.new(500, p.payload, 'Error from register_first_stake_account', e)
    end
  end

  # Register the primary_account in the database. This step will also set the
  # batch_uuid that will be used in later steps. Since we are working with data
  # submitted online, we will also make sure that the N value is within our
  # acceptable range.
  def register_first_stake_account
    lambda do |p|
      return p unless p.code == 200
      # Create a DB record for the first stake account in a batch.
      # Guard against someone submitting split_n_ways that is too big
      split_n_ways = p.payload[:split_n_ways]
      split_n_max = p.payload[:split_n_max]
      split_n = split_n_ways > split_n_max ? split_n_max : split_n_ways

      ssa = p.payload[:solana_stake_account]
      sbsa = StakeBoss::StakeAccount.create!(
        network: p.payload[:network],
        address: ssa.address,
        account_balance: ssa.account_balance,
        activating_stake: ssa.activating_stake,
        activation_epoch: ssa.activation_epoch,
        active_stake: ssa.active_stake,
        credits_observed: ssa.credits_observed,
        deactivation_epoch: ssa.deactivation_epoch,
        delegated_stake: ssa.delegated_stake,
        delegated_vote_account_address: ssa.delegated_vote_account_address,
        epoch: ssa.epoch,
        epoch_rewards: ssa.epoch_rewards,
        lockup_custodian: ssa.lockup_custodian,
        lockup_timestamp: ssa.lockup_timestamp,
        rent_exempt_reserve: ssa.rent_exempt_reserve,
        stake_authority: ssa.stake_authority,
        stake_type: ssa.stake_type,
        withdraw_authority: ssa.withdraw_authority,
        batch_uuid: SecureRandom.uuid,
        split_n_ways: split_n,
        primary_account: true
      )
      Pipeline.new(
        200,
        p.payload.merge(
          stake_boss_stake_account: sbsa, batch_uuid: sbsa.batch_uuid
        )
      )
    rescue StandardError, StakeBossLogic::InvalidStakeAccount => e
      Pipeline.new(500, p.payload, 'Error from register_first_stake_account', e)
    end
  end

  # This is the step where we split the primary account into smaller accounts.
  # This function should only be run once per batch. We will set the value for
  # `split_on` when we are done.
  #
  # There will be extra logging here so we can keep tabs on processing. If we
  # have a problem, I may need to re-build the current state from the logs. Use
  # log level WARN here so I can see the entries on the production server.

  def split_primary_account
      # Within a loop, select one account record from this batch in
      # `delegated_stake desc` order and split it by executing a command on-
      # chain. Also create a new DB record for the new account. Repeat this
      # loop until we have `split_n_ways` records in the DB. We should have N
      # equal sized stake accounts when we are done. None of the stake
      # accounts should be delegated at this point.
      #
      # The split command will look like this (testnet). In this example,
      # BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuY is the stake account
      # address.
      #
      # TODO: Explicitly include max commitment level.
      #
      # % solana split-stake \
      # --url testnet \
      # --stake-authority BossttsdneANBePn2mJhooAewt3fo4aLg7enmpgMvdoH.json \
      # --fee-payer BossttsdneANBePn2mJhooAewt3fo4aLg7enmpgMvdoH.json \
      # BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuY \
      # BossttsdneANBePn2mJhooAewt3fo4aLg7enmpgMvdoH.json --seed 1 \
      # 200
      #
      # The seed value should be incremented each time. Treat it like a simple
      # nonce.  If we create the DB record before making the split, we can use
      # the DB record ID as the seed. By using the record ID as the seed, we can
      # always re-create an address if needed.
      #
      # The final value (200) should be calculated as 1/2 of the current
      # delegated_stake
      #
      # Experiment with cases where we receive a stake account that is already
      # delegated to validator. Is the new account, after the split, delegated
      # to the previous validator? If so, we may need to assign the
      # primary_account to BlockLogic before making the split.
      #
      # We should create an initializer that returns the absolute path to the
      # Boss*.json key file on the development/production server.

    lambda do |p|
      return p unless p.code == 200
      # Make sure we are splitting a primary account
      raise InvalidStakeAccount, 'Not the primary_account' \
        unless p.payload[:stake_boss_stake_account].primary_account?

      # Make sure we haven't already split this one
      raise InvalidStakeAccount, 'Already split' \
        unless p.payload[:stake_boss_stake_account].split_on.nil?
      (p.payload[:split_n_ways] - 1).times do |n|
        # select account to split
        split_account = StakeBoss::StakeAccount.where(
          batch_uuid: p.payload[:batch_uuid]
        ).order(delegated_stake: :desc).first

        # create new stake boss account record
        new_acc = create_split_account(
          network: p.payload[:network],
          batch: p.payload[:batch_uuid],
          split_account: split_account,
          urls: p.payload[:config_urls]
        )

        new_acc_address = find_address_by_seed(
          seed: new_acc.id,
          urls: p.payload[:config_urls]
        )

        new_acc_from_cli = account_from_cli(
          address: new_acc_address,
          urls: p.payload[:config_urls]
        )

        new_acc.update(
          address: new_acc_from_cli.address,
          account_balance: new_acc_from_cli.account_balance,
          activating_stake: new_acc_from_cli.activating_stake,
          activation_epoch: new_acc_from_cli.activation_epoch,
          active_stake: new_acc_from_cli.active_stake,
          credits_observed: new_acc_from_cli.credits_observed,
          deactivation_epoch: new_acc_from_cli.deactivation_epoch,
          delegated_stake: new_acc_from_cli.delegated_stake,
          delegated_vote_account_address: new_acc_from_cli.delegated_vote_account_address,
          epoch: new_acc_from_cli.epoch,
          epoch_rewards: new_acc_from_cli.epoch_rewards,
          lockup_custodian: new_acc_from_cli.lockup_custodian,
          lockup_timestamp: new_acc_from_cli.lockup_timestamp,
          rent_exempt_reserve: new_acc_from_cli.rent_exempt_reserve,
          stake_authority: new_acc_from_cli.stake_authority,
          stake_type: new_acc_from_cli.stake_type,
          withdraw_authority: new_acc_from_cli.withdraw_authority
        )
      end

      Pipeline.new(
        200,
        p.payload
      )
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from split_primary_account', e)
    end
  end

  # This is the step where we delegate validators to the batch. This step can
  # be run just after splitting a new account OR once per epoch to re-delegate
  # validators for a given batch.
  def delegate_validators_for_batch
    lambda do |p|
      return p unless p.code == 200
      # Collect the list of current_validators from the DB.
      #
      # Get the list of top_validators from the select_validators pipeline
      # function.
      #
      # Calculate the difference between the current_validators and the
      # top_validators. Determine which validators should be swapped out and
      # which validators should go in.
      #
      # BlockLogic will always have at least one delegation from the
      # primary_account. If the primary_account was already delegated when we
      # got the authority, we should re-asssign away from the existing
      # validator to BlockLogic. BlockLogic will also be eligible for a second
      # delegation if justified by on-chain performance.
      #
      # Grab the primary_account for the given batch and read the value for
      # `split_n_ways` from that. Also count the number of stake accounts in
      # that batch and make sure the counts match. Raise an error and notify an
      # admin of all errors inside this function.
      #
      # If this is the first time we have run a batch, the current_validators
      # set will be empty and we can simply loop through and assign validators
      # from the top_validators list.
      #
      # Otherwise, we will use the difference sets to find the stake account
      # for each validator that we want to remove and replace with a top
      # performer.
      #
      # Execute the CHANGED delegations on the blockchain. Don't spend the tx
      # fees if the validator doesn't change.
      #
      # Update the DB records.
      #
      # The solana command looks like this (testnet). In this example,
      # 2TqbsD5tW1bNRCZpRSDq7CejLVJwMNwuouvPaMdSdrk2 is the stake account
      # address, and 38QX3p44u4rrdAYvTh2Piq7LvfVps9mcLV9nnmUmK28x is the
      # validator.
      #
      # % solana delegate-stake \
      # --url testnet \
      # --stake-authority BossttsdneANBePn2mJhooAewt3fo4aLg7enmpgMvdoH.json \
      # 2TqbsD5tW1bNRCZpRSDq7CejLVJwMNwuouvPaMdSdrk2 \
      # 38QX3p44u4rrdAYvTh2Piq7LvfVps9mcLV9nnmUmK28x \
      # --fee-payer BossttsdneANBePn2mJhooAewt3fo4aLg7enmpgMvdoH.json
      #

      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(
        500, p.payload, 'Error from delegate_validators_for_batch', e
      )
    end
  end

  # get accound address based on STAKE_BOSS_ADDRESS and account id
  def find_address_by_seed(seed:, urls:)
    new_acc_address = cli_request("create-address-with-seed --from #{STAKE_BOSS_ADDRESS} #{seed} STAKE", urls)
    new_acc_address['cli_response']
  end

  def create_split_account(network:, batch:, split_account:, urls:)
    new_acc = StakeBoss::StakeAccount.new(
      network: network,
      primary_account: false,
      batch_uuid: batch
    )

    if new_acc.save
      request_str = ['split-stake']
      request_str.push "--stake-authority #{STAKE_BOSS_KEYPAIR_FILE} "
      request_str.push "--fee-payer #{STAKE_BOSS_KEYPAIR_FILE} "
      request_str.push "--commitment finalized "
      request_str.push "#{split_account.address} "
      request_str.push "#{STAKE_BOSS_KEYPAIR_FILE} "
      request_str.push "--seed #{new_acc.id} "
      request_str.push lamports_to_sol(split_account.account_balance / 2).to_s
      request_str = request_str.join(' ')
      puts request_str
      Rails.logger.tagged('SPLIT_ACCOUNT') {
        Rails.logger.warn(request_str)
      }
      # create split account
      cli_request(request_str, urls)
      return new_acc
    else
      raise InvalidStakeAccount, 'New account could not be created'
    end
  end

  def account_from_cli(address:, urls:)
    new_acc_from_cli = Solana::StakeAccount.new(
      address: address,
      rpc_urls: urls
    )
    new_acc_from_cli.get
    new_acc_from_cli
  end
end
