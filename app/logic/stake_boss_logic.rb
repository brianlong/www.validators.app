# frozen_string_literal: true

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
# payload = {
#   config_urls: ['https://testnet.solana.com:8899'],
#   network: args['network'],
#   stake_account: args['stake_account']
# }
#
# _p = Pipeline.new(200, payload)
#              .then(&guard_input)
#              .then(&guard_stake_account)

require 'timeout'
require 'base58'

module StakeBossLogic
  # include PipelineLogic
  RPC_TIMEOUT = 60 # seconds

  # InvalidStakeAccount is a custom Error class with a default message for
  # invalid Stake Accounts
  #
  # raise InvalidStakeAccount.new('Blank Address') creates a new Error (e):
  #   e.class: StakeBossLogic::InvalidStakeAccount
  #   e.message: 'Invalid Stake Account: Blank Address'
  class InvalidStakeAccount < StandardError
    attr_accessor :message
    def initialize(message = nil)
      @message = "Invalid Stake Account: #{message}".strip
    end
  end

  # Guard against invalid or malicious input
  def guard_input
    lambda do |p|
      # Make sure the address is not blank
      raise InvalidStakeAccount.new('Blank Address') \
        if p.payload[:stake_account].blank?

      # Make sure the address does not contain script
      raise InvalidStakeAccount.new('Hi Leo, javascript is not allowed!') \
        if p.payload[:stake_account].include?('<script')

      # Make sure the base58 decoded address is the right length (33 bytes)
      raise InvalidStakeAccount.new("Address is wrong size") \
        if Base58.base58_to_binary(p.payload[:stake_account]).bytes.length != 33

      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from guard_input', e)
    end
  end

  # Make sure that we have a valid stake account, that we possess the
  # StakeAuthority, and the balance is > zero
  def guard_stake_account
    lambda do |p|
      # Check the blockchain to see if this is a valid stake account
      stake_account = Solana::StakeAccount.new(
                        address: p.payload[:stake_account],
                        rpc_urls: p.payload[:config_urls]
                      )
      stake_account.get

      raise InvalidStakeAccount.new('Not a valid Stake Account') \
        unless stake_account.is_valid?

      raise InvalidStakeAccount.new('Stake Boss needs Stake Authority') \
        unless stake_account.stake_authority == STAKE_BOSS_ADDRESS

      Pipeline.new(200, p.payload.merge(solana_stake_account: stake_account))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from guard_input', e)
    end
  end
end
