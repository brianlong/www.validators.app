# frozen_string_literal: true

require 'test_helper'

# StakeLogicTest
class StakeLogicTest < ActiveSupport::TestCase
  include StakeLogic

  def setup
    @testnet_url = 'https://api.testnet.solana.com'
    @mainnet_url = 'https://api.mainnet-beta.solana.com'

    @batch = create(:batch, network: 'testnet', gathered_at: DateTime.now, scored_at: DateTime.now)

    # Create our initial payload with the input values
    @initial_payload = {
      # config_urls: Rails.application.credentials.solana[:testnet_urls],
      config_urls: [
        @testnet_url
      ],
      network: 'testnet'
    }
    @previous_epoch = create(:epoch_wall_clock, network: "testnet", epoch: 1, created_at: 2.5.days.ago)
    @current_epoch = create(:epoch_wall_clock, network: "testnet", epoch: 2)
    @json_data = file_fixture("stake_accounts.json").read
  end

  test "check_current_epoch \
        when there is no recent stake account \
        should return 200" do
    p = Pipeline.new(200, @initial_payload)
                .then(&check_current_epoch)

    assert_equal 200, p.code
    assert_equal @current_epoch.epoch, p.payload[:current_epoch]
  end

  test "check_current_epoch \
        when there is recent stake account \
        should return 300" do

    create(:stake_account, epoch: @current_epoch.epoch)

    p = Pipeline.new(200, @initial_payload)
                .then(&check_current_epoch)

    assert_equal 300, p.code
    assert_equal @current_epoch.epoch, p.payload[:current_epoch]
  end

  test 'get_last_batch' do
    p = Pipeline.new(200, @initial_payload)
                .then(&get_last_batch)
    assert_not_nil p[:payload][:batch]
    assert p[:payload][:batch].uuid.include?('-')
  end

  test "move_current_stakes_to_history" do
    create(:stake_account, batch_uuid: "old-batch", epoch: @current_epoch.epoch)

    SolanaCliService.stub(:request, @json_data, ['stakes', @testnet_url]) do
      p = Pipeline.new(200, @initial_payload)
                  .then(&get_last_batch)
                  .then(&move_current_stakes_to_history)

      assert_equal 1, StakeAccountHistory.count
      assert_equal 'old-batch', StakeAccountHistory.last.batch_uuid
    end
  end

  test "get_stake_accounts \
        when getting correct response \
        should save correct payload" do
    authority = 'H2qwtMNNFh6euD3ym4HLgpkbNY6vMdf5aX5bazkU4y8b'
    create(:stake_pool, authority: authority, network: 'testnet')

    SolanaCliService.stub(:request, @json_data, ['stakes', @testnet_url]) do
      p = Pipeline.new(200, @initial_payload)
                  .then(&get_last_batch)
                  .then(&get_stake_accounts)

      assert_not_nil p[:payload][:stake_accounts]
      assert_equal JSON.parse(@json_data).select { |sa| sa['withdrawer'] == authority }.count,
        p[:payload][:stake_accounts].count
    end
  end

  test "update_stake_accounts" do
    authority = "H2qwtMNNFh6euD3ym4HLgpkbNY6vMdf5aX5bazkU4y8b"
    network = "testnet"
    create(:stake_pool, authority: authority, network: network)

    3.times do |n|
      val = create(:validator, account: "validator#{n}", network: network)

      create(
        :vote_account,
        network: network,
        account: "4tFDvWiZgF5yM4UAtnQ6TZcPwFQeLNc2tA4iEjQPZGGL",
        validator: val,
        is_active: false
      )
    end

    VoteAccount.last.update(is_active: true)

    SolanaCliService.stub(:request, @json_data, ['stakes', @testnet_url]) do
      p = Pipeline.new(200, @initial_payload)
                  .then(&get_last_batch)
                  .then(&get_stake_accounts)
                  .then(&update_stake_accounts)

      sa_with_val = StakeAccount.where.not(validator_id: nil).first

      assert_equal [true], sa_with_val.validator.vote_accounts.pluck(:is_active).uniq
      assert_equal p[:payload][:stake_accounts].count, StakeAccount.count
      assert StakeAccount.where.not(batch_uuid: @batch.uuid).empty?

    end
  end

  test 'assign_stake_pools' do
    authority = 'mvines9iiHiQTysrwkJjGf2gb9Ex9jXJX8ns3qwf2kN'
    stake_pool = create(
      :stake_pool,
      network: 'testnet',
      authority: authority
    )

    create(:epoch_wall_clock, network: "testnet", epoch: 5)

    SolanaCliService.stub(:request, @json_data, ['stakes', @testnet_url]) do
      p = Pipeline.new(200, @initial_payload)
                  .then(&get_last_batch)
                  .then(&get_stake_accounts)
                  .then(&update_stake_accounts)
                  .then(&assign_stake_pools)

      assert_equal 200, p.code
      assert_equal stake_pool.id, StakeAccount.where(
        withdrawer: authority
      ).first.stake_pool_id
    end
  end

  test "update_stake_pools" do
    validator = create(
      :validator,
      network: "testnet",
      account: "account123",
      created_at: 10.days.ago
    )

    score = create(
      :validator_score_v1,
      validator: validator,
      skipped_slot_history: [2, 5],
      delinquent: true,
      network: "testnet"
    )

    stake_pool = create(
      :stake_pool,
      network: "testnet",
      average_validators_commission: nil,
      average_uptime: nil,
      average_lifetime: nil,
      average_score: nil,
      average_skipped_slots: nil
    )

    stake_account = create(
      :stake_account,
      stake_pool: stake_pool,
      delegated_vote_account_address: "vote_acc",
      network: "testnet",
      validator: validator
    )

    payload = @initial_payload.merge(stake_pools: [stake_pool])
    p = Pipeline.new(200, payload)
                .then(&update_stake_pools)

    assert stake_pool.average_validators_commission
    assert stake_pool.average_uptime
    assert stake_pool.average_lifetime
    assert stake_pool.average_score
    assert stake_pool.average_skipped_slots
    assert stake_pool.delinquent_count
  end

  test "count average_score" do
    stake_pool = create(:stake_pool)
    validator = create(:validator)
    validator2 = create(:validator)
    score = create(:validator_score_v1, validator: validator)
    score2 = create(:validator_score_v1, validator: validator2)
    score.update_columns(total_score: 10)
    score2.update_columns(total_score: 1)
    create(:stake_account, validator: validator, stake_pool: stake_pool, active_stake: 2)
    create(:stake_account, validator: validator2, stake_pool: stake_pool, active_stake: 6)

    refute stake_pool.average_score

    payload = @initial_payload.merge(stake_pools: [stake_pool])
    Pipeline.new(200, payload).then(&update_stake_pools)

    assert_equal 3.25, stake_pool.reload.average_score

    score2.update_columns(total_score: 6)
    Pipeline.new(200, payload).then(&update_stake_pools)

    assert_equal 7.0, stake_pool.reload.average_score

    validator3 = create(:validator)
    score3 = create(:validator_score_v1, validator: validator3)
    score3.update_columns(total_score: nil)
    create(:stake_account, validator: validator3, stake_pool: stake_pool)
    Pipeline.new(200, payload).then(&update_stake_pools)

    assert_equal 0.52, stake_pool.reload.average_score

    score3.update_columns(total_score: 4)
    create(:stake_account, validator: validator3, stake_pool: stake_pool)
    Pipeline.new(200, payload).then(&update_stake_pools)

    assert_equal 4.12, stake_pool.reload.average_score
  end

  test "get_rewards_from_stake_pools \
        when response is correct \
        should have correct payload" do
    stake_pool = create(:stake_pool)
    validator = create(:validator)
    validator2 = create(:validator)
    score = create(:validator_score_v1, validator: validator)
    score2 = create(:validator_score_v1, validator: validator2)
    score.update_columns(total_score: 10)
    score2.update_columns(total_score: 9)
    create(:stake_account, validator: validator, stake_pool: stake_pool)
    create(:stake_account, validator: validator2, stake_pool: stake_pool)

    VCR.use_cassette("stake_logic_get_rewards_from_stake_pools") do
      p = Pipeline.new(200, @initial_payload)
                  .then(&get_rewards_from_stake_pools)

      refute p.payload[:account_rewards].empty?
    end
  end

  test "assign_epochs adds correct values to payload" do
    p = Pipeline.new(200, @initial_payload)
                .then(&assign_epochs)

    assert_equal @previous_epoch, p.payload[:previous_epoch]
    assert_equal @current_epoch, p.payload[:current_epoch]
  end

  test "calculate_apy_for_accounts should return correct apy" do
    stake_pool = create(:stake_pool)

    acc = create(
      :stake_account,
      network: "testnet",
      delegated_stake: 2922232803431,
      epoch: 2,
      stake_pubkey: "pubkey_123",
      stake_pool: stake_pool
    )

    @initial_payload.merge!(
      account_rewards: {
        "pubkey_123" => {
          "amount": 2836404516,
          "commission": 10,
          "effectiveSlot": 113276257,
          "epoch": 2,
          "postBalance": 2922232803431,
        }
      },
      current_epoch: @current_epoch,
      previous_epoch: @previous_epoch
    )
    p = Pipeline.new(200, @initial_payload)
                .then(&calculate_apy_for_accounts)

    acc.reload
    assert_equal 200, p.code
    assert_equal 15.2432, acc.apy
  end

  test "calculate_apy_for_accounts returns nil apy if there are no rewards" do
    acc = create(
      :stake_account,
      network: "testnet",
      delegated_stake: 2922232803431,
      epoch: 2,
      stake_pubkey: "pubkey_123",
      apy: 1234
    )

    @initial_payload.merge!(
      account_rewards: {},
      current_epoch: @current_epoch,
      previous_epoch: @previous_epoch
    )
    p = Pipeline.new(200, @initial_payload)
                .then(&calculate_apy_for_accounts)

    acc.reload
    assert_equal 200, p.code
    assert_nil acc.apy
  end

  test "calculate_apy_for_pools should return correct average apy" do
    stake_pool = create(:stake_pool, network: "testnet")

    create(
      :stake_account_history,
      network: "testnet",
      delegated_stake: 2893868758268,
      epoch: 1,
      stake_pubkey: "pubkey_123",
      stake_pool_id: stake_pool.id
    )

    acc = create(
      :stake_account,
      network: "testnet",
      delegated_stake: 2922232803431,
      epoch: 2,
      stake_pubkey: "pubkey_123",
      stake_pool_id: stake_pool.id,
      apy: 12.5502
    )

    @initial_payload.merge!(
      stake_pools: [stake_pool],
      previous_epoch: @previous_epoch,
      account_rewards: {
        "pubkey_123" => {
          "amount": 2836404516,
          "commission": 10,
          "effectiveSlot": 113276257,
          "epoch": 2,
          "postBalance": 2922232803431
        }
      }
    )
    p = Pipeline.new(200, @initial_payload)
                .then(&calculate_apy_for_pools)

    acc.reload
    assert_equal 200, p.code
    assert_equal 12.5502, stake_pool.average_apy
  end

  test "calculate_apy_for_pools should return correct average apy for lido" do
    stake_pool = create(:stake_pool, network: "testnet", name: "Lido")
    val = create(:validator, account: "lido_account")
    create(:validator_history, account: "lido_account", active_stake: 100, validator: val)

    create(
      :stake_account_history,
      network: "testnet",
      delegated_stake: 2893868758268,
      epoch: 1,
      stake_pubkey: "pubkey_123",
      stake_pool_id: stake_pool.id
    )

    acc = create(
      :stake_account,
      network: "testnet",
      delegated_stake: 2922232803431,
      epoch: 2,
      stake_pubkey: "pubkey_123",
      stake_pool_id: stake_pool.id,
      apy: 12.5502,
      validator: val
    )

    @initial_payload.merge!(
      stake_pools: [stake_pool],
      previous_epoch: @previous_epoch,
      account_rewards: {
        "pubkey_123" => {
          "amount": 2836404516,
          "commission": 10,
          "effectiveSlot": 113276257,
          "epoch": 2,
          "postBalance": 2922232803431
        }
      },
      lido_histories: ValidatorHistory.all.select(:account, :active_stake)
    )
    p = Pipeline.new(200, @initial_payload)
                .then(&calculate_apy_for_pools)

    acc.reload
    assert_equal 200, p.code
    assert_equal 12.5502, stake_pool.average_apy
  end

  test "calculate_apy_for_pools returns nil if there's no stake" do
    stake_pool = create(:stake_pool, network: "testnet")

    create(
      :stake_account_history,
      network: "testnet",
      delegated_stake: 0,
      active_stake: 0,
      epoch: 1,
      stake_pubkey: "pubkey_123",
      stake_pool_id: stake_pool.id
    )

    acc = create(
      :stake_account,
      network: "testnet",
      delegated_stake: 0,
      active_stake: 0,
      epoch: 2,
      stake_pubkey: "pubkey_123",
      stake_pool_id: stake_pool.id,
      apy: 12.5502
    )

    @initial_payload.merge!(
      stake_pools: [stake_pool],
      previous_epoch: @previous_epoch,
      account_rewards: {
        "pubkey_123" => {
          "amount": 2836404516,
          "commission": 10,
          "effectiveSlot": 113276257,
          "epoch": 2,
          "postBalance": 0
        }
      }
    )
    p = Pipeline.new(200, @initial_payload)
                .then(&calculate_apy_for_pools)

    acc.reload
    assert_equal 200, p.code
    assert_nil stake_pool.average_apy
  end
end
