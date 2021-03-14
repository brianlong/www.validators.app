# frozen_string_literal: true

require 'test_helper'

# Valid regular account: testarBnsk6ZVZWthoBAmbn5wyA35Nc2Dr7QWWV9TRv
# Valid stake account:   BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuY

# SolanaLogicTest
class SolanaStakeAccountTest < ActiveSupport::TestCase
  # include SolanaLogic

  test 'the truth' do
    assert true
  end

  test 'get valid stake account' do
    address = 'BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuY'
    json_data = \
      File.read("#{Rails.root}/test/stubs/solana_stake_account_#{address}.json")
    SolanaCliService.stub(
                          :request,
                          json_data,
                          [address, TESTNET_CLUSTER_URLS]
                         ) do

      stake_account = Solana::StakeAccount.new(
                        address: address,
                        rpc_urls: TESTNET_CLUSTER_URLS
                      )
      stake_account.get
      # puts stake_account.inspect
      assert       stake_account.is_valid?
      assert       stake_account.is_active?
      assert_equal 'BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuY',
                   stake_account.address
      assert_equal 200000000000,
                   stake_account.account_balance
      assert_equal 168,
                   stake_account.activation_epoch
      assert_equal 199997717120,
                   stake_account.active_stake
      assert_equal 25080388,
                   stake_account.credits_observed
      assert_nil   stake_account.deactivation_epoch
      assert_equal 199997717120,
                   stake_account.delegated_stake
      assert_equal 'HiFjzpR7e5Kv2tdU9jtE4FbH1X8Z9Syia3Uadadx18b5',
                   stake_account.delegated_vote_account_address
      assert_equal [],
                   stake_account.epoch_rewards
      assert_nil   stake_account.epoch
      assert_nil   stake_account.lockup_custodian
      assert_nil   stake_account.lockup_timestamp
      assert_equal 2282880,
                   stake_account.rent_exempt_reserve
      assert_equal 'BossttsdneANBePn2mJhooAewt3fo4aLg7enmpgMvdoH',
                   stake_account.stake_authority
      assert_equal 'Stake',
                   stake_account.stake_type
      assert_equal '71bhKKL89U3dNHzuZVZ7KarqV6XtHEgjXjvJTsguD11B',
                   stake_account.withdraw_authority
    end
  end

  test 'get invalid stake account' do
    address = 'BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuZ'
    json_data = \
      File.read("#{Rails.root}/test/stubs/solana_stake_account_#{address}.json")
    SolanaCliService.stub(
                          :request,
                          json_data,
                          [address, TESTNET_CLUSTER_URLS]
                         ) do

      stake_account = Solana::StakeAccount.new(
                        address: address,
                        rpc_urls: TESTNET_CLUSTER_URLS
                      )
      stake_account.get
      refute         stake_account.is_valid?
      refute         stake_account.is_active?
      assert_equal   'BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuZ',
                     stake_account.address
      assert_not_nil stake_account.error
      refute         stake_account.is_valid?

    end
  end

  test 'get locked undelegated stake' do
    address = '2tgq1PZGanqgmmLcs3PDx8tpr7ny1hFxaZc2LP867JuS'
    json_data = \
      File.read("#{Rails.root}/test/stubs/solana_stake_account_#{address}.json")
    SolanaCliService.stub(
                          :request,
                          json_data,
                          [address, TESTNET_CLUSTER_URLS]
                         ) do

      stake_account = Solana::StakeAccount.new(
                        address: address,
                        rpc_urls: TESTNET_CLUSTER_URLS
                      )
      stake_account.get
      # puts stake_account.inspect
      assert       stake_account.is_valid?
      refute       stake_account.is_active?
      assert_equal '2tgq1PZGanqgmmLcs3PDx8tpr7ny1hFxaZc2LP867JuS',
                   stake_account.address
      assert_equal 104166666268940,
                   stake_account.account_balance
      assert_equal 149,
                   stake_account.activation_epoch
      assert_nil   stake_account.active_stake
      assert_equal 54496405,
                   stake_account.credits_observed
      assert_equal 149,
                   stake_account.deactivation_epoch
      assert_equal 104166663986060,
                   stake_account.delegated_stake
      assert_equal '9GJmEHGom9eWo4np4L5vC6b6ri1Df2xN8KFoWixvD1Bs',
                   stake_account.delegated_vote_account_address
      assert_equal [],
                   stake_account.epoch_rewards
      assert_equal 0,
                   stake_account.epoch
      assert_equal 'Mc5XB47H3DKJHym5RLa9mPzWv5snERsF3KNv5AauXK8',
                   stake_account.lockup_custodian
      assert_equal 1657314000,
                   stake_account.lockup_timestamp
       assert_equal 2282880,
                    stake_account.rent_exempt_reserve
       assert_equal '8F5yQQLSTnFVweVAj8e7kcjfDBjTZEo7XxcnShGJVYAZ',
                    stake_account.stake_authority
       assert_equal 'Stake',
                    stake_account.stake_type
       assert_equal '3zViUB98aYn4eFDLb1Bfg2gp3bX5VZ3iQUgYcc3QTmF3',
                    stake_account.withdraw_authority

    end
  end
end
