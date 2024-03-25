# frozen_string_literal: true

require 'test_helper'

class StakeAccountQueryTest < ActiveSupport::TestCase

  setup do
    data_center = create(:data_center, :china)
    data_center_host = create(:data_center_host, data_center: data_center)

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

    create(:validator_ip, :active, validator: @validator, data_center_host: data_center_host)

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
      active_stake: nil,
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

    stake_accounts_query = StakeAccountQuery.new(
      network: 'testnet',
      filter_account: nil,
      filter_staker: nil,
      filter_withdrawer: nil,
      filter_validator: nil
    )

    stake_accounts = stake_accounts_query.all_records

    assert_equal 2, stake_accounts.size
    assert_equal 1, stake_accounts.first.activation_epoch
    refute stake_accounts.where(active_stake: nil).exists?
  end

  test "returns all fields declared in query class" do
    stake_accounts_query = StakeAccountQuery.new(
      network: "testnet",
      filter_account: nil,
      filter_staker: nil,
      filter_withdrawer: nil,
      filter_validator: nil
    )

    number_of_fields =
      StakeAccountQuery::STAKE_ACCOUNT_FIELDS.size +
      StakeAccountQuery::STAKE_POOL_FIELDS.size +
      StakeAccountQuery::VALIDATOR_FIELDS.size +
      StakeAccountQuery::VALIDATOR_SCORE_V1_FIELDS.size

    stake_accounts = stake_accounts_query.all_records

    assert_equal number_of_fields, stake_accounts.first.attributes.size
  end

  test 'when filter_account provided return correct records' do

    stake_accounts_query = StakeAccountQuery.new(
      network: 'testnet',
      sort_by: nil,
      filter_account: 'stake_pubkey_1',
      filter_staker: nil,
      filter_withdrawer: nil,
      filter_validator: nil
    )

    stake_accounts = stake_accounts_query.all_records

    assert_equal 1, stake_accounts.size
    assert_equal 'stake_pubkey_1', stake_accounts.first.stake_pubkey
    refute stake_accounts.where(active_stake: nil).exists?
  end

  test 'when filter_staker provided return correct records' do

    stake_accounts_query = StakeAccountQuery.new(
      network: 'testnet',
      sort_by: nil,
      filter_account: nil,
      filter_staker: 'staker_key',
      filter_withdrawer: nil,
      filter_validator: nil
    )

    stake_accounts = stake_accounts_query.all_records

    assert_equal 1, stake_accounts.size
    assert_equal 'staker_key', stake_accounts.first.staker
    refute stake_accounts.where(active_stake: nil).exists?
  end

  test 'when filter_withdrawer provided return correct records' do

    stake_accounts_query = StakeAccountQuery.new(
      network: 'testnet',
      sort_by: nil,
      filter_account: nil,
      filter_staker: nil,
      filter_withdrawer: @stake_pool.authority,
      filter_validator: nil
    )

    stake_accounts = stake_accounts_query.all_records

    assert_equal 1, stake_accounts.size
    assert_equal @stake_pool.authority, stake_accounts.first.withdrawer
    refute stake_accounts.where(active_stake: nil).exists?
  end

  test 'when filter_validator provided return correct records' do

    stake_accounts_query = StakeAccountQuery.new(
      network: 'testnet',
      sort_by: nil,
      filter_account: nil,
      filter_staker: nil,
      filter_withdrawer: nil,
      filter_validator: @validator.name
    )

    stake_accounts = stake_accounts_query.all_records

    assert_equal 1, stake_accounts.size
    assert_equal @validator.name, stake_accounts.first.validator_name
    refute stake_accounts.where(active_stake: nil).exists?
  end

end
