require 'test_helper'

class StakeAccountQueryTest < ActiveSupport::TestCase

  setup do
    @stake_pool = create(
      :stake_pool,
      authority: 'stake_pool_authority',
      name: 'SP',
      network: 'testnet'
    )

    @validator = create(
      :validator,
      :with_score,
      network: 'testnet',
      name: 'test_val',
      account: 'val_account'
    )

    create(
      :stake_account,
      active_stake: 100,
      delegated_stake: 100,
      staker: 'staker_key',
      withdrawer: @stake_pool.authority,
      network: 'testnet',
      stake_pubkey: 'stake_pubkey_1',
      validator: @validator,
      stake_pool: @stake_pool,
      activation_epoch: 1,
      batch_uuid: 'batch'
    )

    create(
      :stake_account,
      active_stake: 200,
      delegated_stake: 200,
      staker: 'diff_staker_key',
      withdrawer: 'diff_withdrawer_key',
      network: 'testnet',
      stake_pubkey: 'diff_stake_pubkey_1',
      activation_epoch: 2,
      batch_uuid: 'batch',
      validator_id: 666
    )
  end

  test 'when no data provided return all records' do
    stake_accounts = StakeAccountQuery.new(
      network: 'testnet',
    ).call

    assert_equal 2, stake_accounts.size
    assert_equal 1, stake_accounts.first.activation_epoch
  end

  test 'when filter_account provided return correct records' do
    stake_accounts = StakeAccountQuery.new(
      network: 'testnet'
    ).call(account: 'stake_pubkey_1')

    assert_equal 1, stake_accounts.size
    assert_equal 'stake_pubkey_1', stake_accounts.first.stake_pubkey
  end

  test 'when filter_staker provided return correct records' do
    stake_accounts = StakeAccountQuery.new(
      network: 'testnet'
    ).call(staker: 'staker_key')

    assert_equal 1, stake_accounts.size
    assert_equal 'staker_key', stake_accounts.first.staker
  end

  test 'when filter_withdrawer provided return correct records' do
    stake_accounts = StakeAccountQuery.new(
      network: 'testnet'
    ).call(withdrawer: @stake_pool.authority)

    assert_equal 1, stake_accounts.size
    assert_equal @stake_pool.authority, stake_accounts.first.withdrawer
  end

  test 'when filter_validator provided return correct records' do
    stake_accounts = StakeAccountQuery.new(
      network: 'testnet'
    ).call(validator_query: @validator.name)

    assert_equal 1, stake_accounts.size
    assert_equal @validator.name, stake_accounts.first.validator_name
  end

  test 'all params' do
    stake_accounts = StakeAccountQuery.new(
      network: 'testnet'
    ).call(
      account: 'stake_pubkey_1',
      staker: 'staker_key',
      withdrawer: @stake_pool.authority,
      sort: 'epoch_desc',
      validator_query: @validator.name
    )

    assert_equal 1, stake_accounts.size
  end
end
