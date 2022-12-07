# frozen_string_literal: true
require 'test_helper'

# CoinGeckoLogicTest
class SolPrices::SharedLogicTest < ActiveSupport::TestCase
  include SolPrices::Parsers::CoinGecko
  include SolPrices::CoinGeckoLogic
  include SolPrices::SharedLogic
  include VcrHelper

  def setup
    # Create our initial payload with the input values

    @namespace = File.join('logic', 'sol_prices', 'shared')
    @initial_payload = {}

    @datetime = DateTime.current.beginning_of_day - 2.days

    @price_example = {
      :exchange=>1,
      :currency=>0,
      :open=>173.515,
      :high=>198.2125,
      :low=>146.6825,
      :close=>190.9625,
      :volume=>571066472.04745,
      :datetime_from_exchange=>@datetime
    }

    setup_epochs
  end

  test '#assign epochs' do
    payload = @initial_payload.merge({ prices_from_exchange: [@price_example] })

    p = Pipeline.new(200, payload)
                .then(&assign_epochs)

    price = p.payload[:prices_from_exchange].first

    assert_equal 201, price[:epoch_testnet]
    assert_equal 205, price[:epoch_mainnet]
  end

  test '#save_sol_prices coin_gecko' do
    payload = @initial_payload.merge(
      {
        exchange: SolPrice.exchanges[:coin_gecko],
        client: CoinGeckoClient.new,
        datetime: DateTime.new(2021,9,8),
        days: 'max'
      }
    )

    vcr_cassette(@namespace, __method__) do
      assert_difference 'SolPrice.count', 136 do
        p = Pipeline.new(200, payload)
                    .then(&get_ohlc_prices)
                    .then(&save_sol_prices)
      end
    end
  end

  test '#find_epochs' do
    result = find_epochs(@price_example)
    expected_result = {
      epoch_testnet: @epoch_history_testnet_2.epoch,
      epoch_mainnet: @epoch_history_mainnet_1.epoch
    }

    assert_equal result, expected_result
  end

  # Helper methods
  def setup_epochs
    @epoch_history_testnet_1 = create(
      :epoch_history,
      network: 'testnet',
      epoch: 200,
      created_at: @datetime - 5.minutes
    )
    @epoch_history_testnet_2 = create(
      :epoch_history,
      network: 'testnet',
      epoch: 201,
      created_at: @datetime + 2.minutes
    ) # closest

    @epoch_history_mainnet_1 = create(
      :epoch_history,
      network: 'mainnet',
      epoch: 205,
      created_at: @datetime - 3.minutes
    ) # closest
    @epoch_history_mainnet_2 = create(
      :epoch_history,
      network: 'mainnet',
      epoch: 206,
      created_at: @datetime + 5.minutes
    )
  end
end
