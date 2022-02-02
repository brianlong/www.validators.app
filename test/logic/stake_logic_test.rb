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

    @json_data = file_fixture("stake_accounts.json").read
  end

  test 'get_last_batch' do
    p = Pipeline.new(200, @initial_payload)
                .then(&get_last_batch)
    assert_not_nil p[:payload][:batch]
    assert p[:payload][:batch].uuid.include?('-')
  end

  test 'move_current_stakes_to_history' do
    create(:stake_account, batch_uuid: 'old-batch')

    SolanaCliService.stub(:request, @json_data, ['stakes', @testnet_url]) do
      p = Pipeline.new(200, @initial_payload)
                  .then(&get_last_batch)
                  .then(&move_current_stakes_to_history)

      assert_equal 1, StakeAccountHistory.count
      assert_equal 'old-batch', StakeAccountHistory.last.batch_uuid
    end
  end

  test 'get_stake_accounts' do
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

  test 'update_stake_accounts' do
    SolanaCliService.stub(:request, @json_data, ['stakes', @testnet_url]) do
      p = Pipeline.new(200, @initial_payload)
                  .then(&get_last_batch)
                  .then(&get_stake_accounts)
                  .then(&update_stake_accounts)

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

  test "update_validator_stats" do
    authority = 'mvines9iiHiQTysrwkJjGf2gb9Ex9jXJX8ns3qwf2kN'

    validator = create(
      :validator,
      network: "testnet",
      account: "account123",
      created_at: 10.days.ago
    )

    validator_history = create(
      :validator_history,
      network: "testnet",
      delinquent: "true",
      created_at: DateTime.now - 3.days,
      account: "account123"
    )

    score = create(
      :validator_score_v1,
      validator: validator,
      skipped_slot_history: [2, 5],
      delinquent: false,
      network: "testnet"
    )

    vote_account = create(
      :vote_account,
      network: "testnet",
      account: "vote_acc"
    )

    stake_pool = create(
      :stake_pool,
      network: "testnet",
      authority: authority
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
                .then(&update_validator_stats)

    assert_equal p.code, 200
    assert_equal 3, stake_pool.average_uptime
    assert_equal 10, stake_pool.average_lifetime
    assert_equal 0, stake_pool.average_delinquent
    assert_equal 5, stake_pool.average_skipped_slots
    assert_equal score.total_score, stake_pool.average_score
  end
  
  test "count_average_validators_commission" do
    stake_pool = create(:stake_pool, network: "testnet")
    validator = create(:validator)
    validator2 = create(:validator)
    score = create(:validator_score_v1, validator: validator, commission: 5)
    score2 = create(:validator_score_v1, validator: validator2, commission: 10)
    stake_account = create(:stake_account, validator: validator, stake_pool: stake_pool)
    stake_account2 = create(:stake_account, validator: validator2, stake_pool: stake_pool)

    refute stake_pool.average_validators_commission

    p = Pipeline.new(200, @initial_payload)
                .then(&count_average_validators_commission)

    assert_equal 7.5, stake_pool.reload.average_validators_commission
  end

  test "count average_score" do
    stake_pool = create(:stake_pool)
    validator = create(:validator)
    validator2 = create(:validator)
    score = create(:validator_score_v1, validator: validator)
    score2 = create(:validator_score_v1, validator: validator2)
    score.update_columns(total_score: 10)
    score2.update_columns(total_score: 9)
    create(:stake_account, validator: validator, stake_pool: stake_pool)
    create(:stake_account, validator: validator2, stake_pool: stake_pool)

    refute stake_pool.average_score

    payload = @initial_payload.merge(stake_pools: [stake_pool])
    Pipeline.new(200, payload).then(&update_validator_stats)

    assert_equal 9.5, stake_pool.reload.average_score

    score2.update_columns(total_score: 6)
    Pipeline.new(200, payload).then(&update_validator_stats)

    assert_equal 8, stake_pool.reload.average_score

    validator3 = create(:validator)
    score3 = create(:validator_score_v1, validator: validator3)
    score3.update_columns(total_score: nil)
    create(:stake_account, validator: validator3, stake_pool: stake_pool)
    Pipeline.new(200, payload).then(&update_validator_stats)

    assert_equal 5.33, stake_pool.reload.average_score

    score3.update_columns(total_score: 4)
    create(:stake_account, validator: validator3, stake_pool: stake_pool)
    Pipeline.new(200, payload).then(&update_validator_stats)

    assert_equal 6.67, stake_pool.reload.average_score
  end

  test "get_rewards" do
    stake_pool = create(:stake_pool)
    validator = create(:validator)
    validator2 = create(:validator)
    score = create(:validator_score_v1, validator: validator)
    score2 = create(:validator_score_v1, validator: validator2)
    score.update_columns(total_score: 10)
    score2.update_columns(total_score: 9)
    create(:stake_account, validator: validator, stake_pool: stake_pool)
    create(:stake_account, validator: validator2, stake_pool: stake_pool)

    VCR.use_cassette("stake_logic_get_rewards") do
      p = Pipeline.new(200, @initial_payload)
                  .then(&get_rewards)

      refute p.payload[:account_rewards].empty?
    end
  end

  test "calculate_apy_for_accounts should return correct apy" do
    create(:epoch_wall_clock, network: "testnet", epoch: 1, created_at: 3.days.ago)
    create(:epoch_wall_clock, network: "testnet", epoch: 2)

    create(
      :stake_account_history,
      network: "testnet",
      delegated_stake: 2893868758268,
      epoch: 1,
      stake_pubkey: "pubkey_123"
    )

    acc = create(
      :stake_account,
      network: "testnet",
      delegated_stake: 2922232803431,
      epoch: 2,
      stake_pubkey: "pubkey_123"
    )

    @initial_payload.merge!(
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
                .then(&calculate_apy_for_accounts)
    
    acc.reload

    assert_equal 200, p.code
    assert_equal 12.5502, acc.apy
  end

  test "calculate_apy_for_pools should return correct average apy" do
    previous_epoch = create(:epoch_wall_clock, network: "testnet", epoch: 1, created_at: 3.days.ago)
    create(:epoch_wall_clock, network: "testnet", epoch: 2)
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
      previous_epoch: previous_epoch,
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
end
