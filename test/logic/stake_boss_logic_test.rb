# frozen_string_literal: true

require 'test_helper'

# Valid regular account: testarBnsk6ZVZWthoBAmbn5wyA35Nc2Dr7QWWV9TRv
# Valid stake account:   BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuY
# Invalid stake account: BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuZ

class StakeBossLogicTest < ActiveSupport::TestCase
  include StakeBossLogic
  include ApplicationHelper

  def setup
    # Create our initial payload with the input values
    @initial_payload = {
      config_urls: ['https://testnet.solana.com:8899'],
      network: 'testnet',
      stake_account: 'BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuY'
    }
  end

  def create_validators
    # Marco Broeken
    @marco = Validator.create(
      network: 'testnet',
      account: '8SQEcP4FaYQySktNQeyxF3w8pvArx3oMEh7fPrzkN9pu',
      name: 'Stakeconomy.com'
    )
    @marco.vote_accounts.create(
      # network: 'testnet',
      account: '2HUKQz7W2nXZSwrdX5RkfS2rLU4j1QZLjdGCHcoUKFh3'
    )
    ValidatorScoreV1.create(
      network: 'testnet',
      validator_id: @marco.id,
      total_score: 10,
      delinquent: false,
      stake_concentration_score: 0,
      data_center_concentration_score: 0,
      data_center_key: '3265-NL-Bergschenhoek'
    )

    # Martin Smith
    @martin = Validator.create(
      network: 'testnet',
      account: '4XWxphAh1Ji9p3dYMNRNtW3sbmr5Z1cvsGyJXJx5Jvfy',
      name: 'Smith'
    )
    @martin.vote_accounts.create(
      # network: 'testnet',
      account: '38QX3p44u4rrdAYvTh2Piq7LvfVps9mcLV9nnmUmK28x'
    )
    ValidatorScoreV1.create(
      network: 'testnet',
      validator_id: @martin.id,
      total_score: 9,
      delinquent: false,
      stake_concentration_score: 0,
      data_center_concentration_score: 0,
      data_center_key: '199610-RU-Moscow'
    )
  end

  # Show that the input guards are working
  test 'guard_input_blank' do
    # Blank input
    p = Pipeline.new(200, @initial_payload.merge(stake_address: nil))
                .then(&guard_input)
    assert_equal 500, p.code
    assert_equal StakeBossLogic::InvalidStakeAccount, p.errors.class
    assert_equal 'Invalid Stake Account: Blank Address', p.errors.message
  end

  test 'guard_input_javascript' do
    # javascript
    account = '"><script src=https://certus.xss.ht></script>'
    p = Pipeline.new(200, @initial_payload.merge(stake_address: account))
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
    p = Pipeline.new(200, @initial_payload.merge(stake_address: 'test'))
                .then(&guard_input)

    assert_equal 500,
                 p.code
    assert_equal StakeBossLogic::InvalidStakeAccount,
                 p.errors.class
    assert_equal 'Invalid Stake Account: Address is wrong size',
                 p.errors.message
  end

  test 'guard_stake_account_not_a_stake_account' do
    address = 'FLC9P4DgGjQD53X1zsx1hA9HJhzjErzYeJk24Xdfpogx'
    json_data = \
      File.read("#{Rails.root}/test/stubs/solana_stake_account_#{address}.json")

    SolanaCliService.stub(
      :request,
      [
        json_data,
        "Error: RPC request error: FLC9P4DgGjQD53X1zsx1hA9HJhzjErzYeJk24Xdfpogx is not a stake account\n"
      ],
      [address, TESTNET_CLUSTER_URLS],
      true
    ) do
      p = Pipeline.new(200, @initial_payload.merge(stake_address: address))
                  .then(&guard_input)
                  .then(&guard_stake_account)

      assert_equal 500,
                   p.code
      assert_equal StakeBossLogic::InvalidStakeAccount,
                   p.errors.class
      assert_equal 'Invalid Stake Account: This is not a Stake Account',
                   p.errors.message
    end
  end

  test 'guard_stake_account_invalid' do
    address = 'BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuZ'
    json_data = \
      File.read("#{Rails.root}/test/stubs/solana_stake_account_#{address}.json")

    SolanaCliService.stub(
      :request,
      json_data,
      [address, TESTNET_CLUSTER_URLS]
    ) do
      p = Pipeline.new(200, @initial_payload.merge(stake_address: address))
                  .then(&guard_input)
                  .then(&guard_stake_account)
      puts p.errors.message
      assert_equal 500,
                   p.code
      assert_equal StakeBossLogic::InvalidStakeAccount,
                   p.errors.class
      assert_equal 'Invalid Stake Account: Not a valid Stake Account',
                   p.errors.message
    end
  end

  test 'guard_stake_account_boss_does_not_have_stake_authority' do
    address = '2tgq1PZGanqgmmLcs3PDx8tpr7ny1hFxaZc2LP867JuS'
    json_data = \
      File.read("#{Rails.root}/test/stubs/solana_stake_account_#{address}.json")

    SolanaCliService.stub(
      :request,
      json_data,
      [address, TESTNET_CLUSTER_URLS]
    ) do
      p = Pipeline.new(200, @initial_payload.merge(stake_address: address))
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

  test 'guard_stake_account_inactive' do
    address = '2TqbsD5tW1bNRCZpRSDq7CejLVJwMNwuouvPaMdSdrk2'
    json_data = \
      File.read("#{Rails.root}/test/stubs/solana_stake_account_#{address}.json")

    SolanaCliService.stub(
      :request,
      json_data,
      [address, TESTNET_CLUSTER_URLS]
    ) do
      p = Pipeline.new(200, @initial_payload.merge(stake_address: address))
                  .then(&guard_input)
                  .then(&guard_stake_account)

      assert_equal 500,
                   p.code
      assert_equal StakeBossLogic::InvalidStakeAccount,
                   p.errors.class
      assert_equal 'Invalid Stake Account: Stake Account is inactive',
                   p.errors.message
    end
  end

  test 'guard_stake_account_success' do
    address = 'BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuY'
    json_data = \
      File.read("#{Rails.root}/test/stubs/solana_stake_account_#{address}.json")

    SolanaCliService.stub(
      :request,
      json_data,
      [address, TESTNET_CLUSTER_URLS]
    ) do
      p = Pipeline.new(200, @initial_payload.merge(stake_address: address))
                  .then(&guard_input)
                  .then(&guard_stake_account)

      assert_equal 200,
                   p.code
      assert       p.payload[:solana_stake_account].valid?
      assert       p.payload[:solana_stake_account].active?
      assert_equal 'BossttsdneANBePn2mJhooAewt3fo4aLg7enmpgMvdoH',
                   p.payload[:solana_stake_account].stake_authority
    end
  end

  test 'guard_duplicate_records' do
    StakeBoss::StakeAccount.create!(
      network: 'testnet',
      address: 'BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuY'
    )

    address = 'BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuY'
    json_data = \
      File.read("#{Rails.root}/test/stubs/solana_stake_account_#{address}.json")

    SolanaCliService.stub(
      :request,
      json_data,
      [address, TESTNET_CLUSTER_URLS]
    ) do
      p = Pipeline.new(200, @initial_payload.merge(stake_address: address))
                  .then(&guard_duplicate_records)

      assert_equal 500, p.code
      assert_equal 'Invalid Stake Account: Duplicate Record', p.errors.message
    end
  end

  test 'split_n_ways' do
    address = 'BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuY'
    json_data = \
      File.read("#{Rails.root}/test/stubs/solana_stake_account_#{address}.json")

    SolanaCliService.stub(
      :request,
      json_data,
      [address, TESTNET_CLUSTER_URLS]
    ) do
      p = Pipeline.new(200, @initial_payload.merge(stake_address: address))
                  .then(&guard_input)
                  .then(&guard_stake_account)
                  .then(&guard_duplicate_records)
                  .then(&set_max_n_split)

      assert_equal 200,
                   p.code
      assert_equal 199,
                   lamports_to_sol(
                     p.payload[:solana_stake_account].delegated_stake
                   )
      assert_equal 2,
                   p.payload[:split_n_ways]
      assert_equal 32,
                   p.payload[:split_n_max]
    end
  end

  test 'select_validators' do
    create_validators

    address = 'BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuY'
    json_data = \
      File.read("#{Rails.root}/test/stubs/solana_stake_account_#{address}.json")

    SolanaCliService.stub(
      :request,
      json_data,
      [address, TESTNET_CLUSTER_URLS]
    ) do
      p = Pipeline.new(200, @initial_payload.merge(stake_address: address))
                  .then(&guard_input)
                  .then(&guard_stake_account)
                  .then(&guard_duplicate_records)
                  .then(&set_max_n_split)
                  .then(&select_validators)

      assert_equal 200,
                   p.code
      assert_equal 199,
                   lamports_to_sol(
                     p.payload[:solana_stake_account].delegated_stake
                   )
      assert_equal 2,
                   p.payload[:split_n_ways]
      assert_equal 32,
                   p.payload[:split_n_max]
      assert_equal 1,
                   p.payload[:validators].count
      assert       p.payload[:validators].include?(
        '2HUKQz7W2nXZSwrdX5RkfS2rLU4j1QZLjdGCHcoUKFh3'
      )
    end
  end

  test 'register_first_stake_account' do
    create_validators

    address = 'BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuY'
    json_data = \
      File.read("#{Rails.root}/test/stubs/solana_stake_account_#{address}.json")

    SolanaCliService.stub(
      :request,
      json_data,
      [address, TESTNET_CLUSTER_URLS]
    ) do
      assert_difference 'StakeBoss::StakeAccount.count' do
        p = Pipeline.new(200, @initial_payload.merge(stake_address: address))
                    .then(&guard_input)
                    .then(&guard_stake_account)
                    .then(&guard_duplicate_records)
                    .then(&set_max_n_split)
                    .then(&select_validators)
                    .then(&register_first_stake_account)

        assert_equal 200,
                     p.code
        assert_equal address,
                     p.payload[:stake_boss_stake_account].address
      end
    end
  end
end
