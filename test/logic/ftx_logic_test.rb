# frozen_string_literal: true
require 'test_helper'

# CoinGeckoLogicTest
class FtxLogicTest < ActiveSupport::TestCase
  include FtxLogic
  include VcrHelper

  def setup
    # Create our initial payload with the input values
    @initial_payload = {
      client: SolPrices::ApiWrappers::FtxMarket.new,
      start_time: DateTime.new(2021,9,8),
      resolution: 86400,
    }
    @namespace = File.join('logic', 'ftx_logic')
    @vcr_name = 'ftx_logic'

    create(:epoch_history, network: 'testnet', epoch: 200)
    create(:epoch_history, network: 'mainnet', epoch: 205)
  end

  test '#get_prices_from_days' do
    vcr_cassette(@namespace, @vcr_name) do
      p = Pipeline.new(200, @initial_payload)
                  .then(&get_prices_from_days)

      assert_not_nil p.payload[:prices_from_exchange]
      assert_equal 3, p.payload[:prices_from_exchange].size

    end
  end

  test '#save_sol_prices' do
    vcr_cassette(@namespace, @vcr_name) do
      assert_difference 'SolPrice.count', 3 do
        p = Pipeline.new(200, @initial_payload)
                    .then(&get_prices_from_days)
                    .then(&save_sol_prices)

        assert_not_nil p.payload[:prices_from_exchange]
      end
    end
  end
end
