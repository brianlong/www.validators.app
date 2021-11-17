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
  end

  test 'get_last_batch' do
    p = Pipeline.new(200, @initial_payload)
                .then(&get_last_batch)
    assert_not_nil p[:payload][:batch]
    assert p[:payload][:batch].uuid.include?('-')
  end

  test 'move_current_stakes_to_history' do
    create(:stake_account, batch_uuid: 'old-batch')
    json_data = File.read("#{Rails.root}/test/json/stake_accounts.json")

    SolanaCliService.stub(:request, json_data, ['stakes', @testnet_url]) do
      p = Pipeline.new(200, @initial_payload)
                  .then(&get_last_batch)
                  .then(&move_current_stakes_to_history)

      assert_equal 1, StakeAccountHistory.count
      assert_equal 'old-batch', StakeAccountHistory.last.batch_uuid
    end
  end

  test 'get_stake_accounts' do
    json_data = File.read("#{Rails.root}/test/json/stake_accounts.json")
    create(:stake_pool, authority: 'H2qwtMNNFh6euD3ym4HLgpkbNY6vMdf5aX5bazkU4y8b', network: 'testnet')

    SolanaCliService.stub(:request, json_data, ['stakes', @testnet_url]) do
      p = Pipeline.new(200, @initial_payload)
                  .then(&get_last_batch)
                  .then(&get_stake_accounts)

      assert_not_nil p[:payload][:stake_accounts]
      assert_equal JSON.parse(json_data).select{ |sa| sa['withdrawer'] == 'H2qwtMNNFh6euD3ym4HLgpkbNY6vMdf5aX5bazkU4y8b'}.count,
        p[:payload][:stake_accounts].count
    end
  end

  test 'save_stake_accounts' do
    json_data = File.read("#{Rails.root}/test/json/stake_accounts.json")

    SolanaCliService.stub(:request, json_data, ['stakes', @testnet_url]) do
      p = Pipeline.new(200, @initial_payload)
                  .then(&get_last_batch)
                  .then(&get_stake_accounts)
                  .then(&save_stake_accounts)

      assert_equal p[:payload][:stake_accounts].count, StakeAccount.count
      assert StakeAccount.where.not(batch_uuid: @batch.uuid).empty?
    end
  end

  test 'assign_stake_pools' do
    json_data = File.read("#{Rails.root}/test/json/stake_accounts.json")
    stake_pool = create(
      :stake_pool,
      network: 'testnet',
      authority: 'mvines9iiHiQTysrwkJjGf2gb9Ex9jXJX8ns3qwf2kN'
    )

    SolanaCliService.stub(:request, json_data, ['stakes', @testnet_url]) do
      p = Pipeline.new(200, @initial_payload)
                  .then(&get_last_batch)
                  .then(&get_stake_accounts)
                  .then(&save_stake_accounts)
                  .then(&assign_stake_pools)

      assert_equal stake_pool.id, StakeAccount.where(
        withdrawer: 'mvines9iiHiQTysrwkJjGf2gb9Ex9jXJX8ns3qwf2kN'
      ).first.stake_pool_id
    end
  end
end
