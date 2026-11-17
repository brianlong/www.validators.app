# frozen_string_literal: true

require "test_helper"

module StakePools
  class UpdateOnChainDataServiceTest < ActiveSupport::TestCase
    setup do
      @jito = create(
        :stake_pool,
        name: "Jito",
        network: "mainnet",
        pool_address: "Jito4APyf642JPZPx3hGc6WWJ8zPKtRbRs4P815Awbb",
        manager_fee: 5
      )
      @invalid = create(
        :stake_pool,
        name: "Invalid",
        network: "mainnet",
        pool_address: "11111111111111111111111111111111",
        manager_fee: 3
      )
      @manual = create(:stake_pool, name: "Manual", network: "mainnet", manager_fee: 9.5)
      @service = UpdateOnChainDataService.new(
        network: "mainnet",
        config_urls: ["https://api.mainnet-beta.solana.com"]
      )
    end

    test "updates fees and token data from stake pool accounts" do
      VCR.use_cassette("services/stake_pools/update_on_chain_data_service") do
        @service.call
      end

      @jito.reload
      assert_equal 4.0, @jito.manager_fee
      assert_equal 0.0, @jito.deposit_fee
      assert_equal 0.1, @jito.withdrawal_fee
      assert_nil @jito.next_manager_fee
      assert @jito.total_lamports.positive?
      assert @jito.pool_token_supply.positive?
      assert @jito.exchange_rate > 1
    end

    test "skips invalid accounts and pools without pool address" do
      VCR.use_cassette("services/stake_pools/update_on_chain_data_service") do
        @service.call
      end

      assert_equal 3.0, @invalid.reload.manager_fee
      assert_nil @invalid.total_lamports
      assert_equal 9.5, @manual.reload.manager_fee
    end
  end
end
