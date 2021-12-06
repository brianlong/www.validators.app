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

    SolanaCliService.stub(:request, @json_data, ['stakes', @testnet_url]) do
      p = Pipeline.new(200, @initial_payload)
                  .then(&get_last_batch)
                  .then(&get_stake_accounts)
                  .then(&update_stake_accounts)
                  .then(&assign_stake_pools)

      assert_equal stake_pool.id, StakeAccount.where(
        withdrawer: authority
      ).first.stake_pool_id
    end
  end

  test 'update_validator_stats' do
    authority = 'mvines9iiHiQTysrwkJjGf2gb9Ex9jXJX8ns3qwf2kN'

    validator = create(
      :validator,
      network: 'testnet',
      account: 'account123'
    )

    validator_history = create(
      :validator_history,
      network: 'testnet',
      delinquent: 'true',
      created_at: DateTime.now - 3.days,
      account: 'account123'
    )

    score = create(
      :validator_score_v1,
      validator: validator,
      skipped_slot_history: [2, 5],
      delinquent: false,
      network: 'testnet'
    )

    vote_account = create(
      :vote_account,
      network: 'testnet',
      account: 'vote_acc'
    )

    stake_pool = create(
      :stake_pool,
      network: 'testnet',
      authority: authority
    )

    stake_account = create(
      :stake_account,
      stake_pool: stake_pool,
      delegated_vote_account_address: 'vote_acc',
      network: 'testnet',
      validator: validator
    )

    payload = @initial_payload.merge(stake_pools: [stake_pool])
    p = Pipeline.new(200, payload)
                .then(&update_validator_stats)

    assert_equal p.code, 200
    assert_equal 3, stake_pool.average_uptime
    assert_equal 0, stake_pool.average_delinquent
    assert_equal 5, stake_pool.average_skipped_slots
  end
end
