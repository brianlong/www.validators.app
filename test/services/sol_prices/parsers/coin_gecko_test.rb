require 'test_helper'

module SolPrices
  module Parsers
    class CoinGeckoTest < ActiveSupport::TestCase
      include VcrHelper
      include Parsers::CoinGecko

      setup do
        @namespace = File.join('services', 'sol_prices', 'parsers', 'coin_gecko')
        @wrapper = ApiWrappers::CoinGecko.new
      end 

      test '#prices_from_ohlc' do
        vcr_cassette(@namespace, __method__) do
          response = @wrapper.ohlc(days: 'max')

          sol_prices_array = prices_from_ohlc(response)

          assert_equal 136, sol_prices_array.size

          assert_difference 'SolPrice.count', 136 do
            SolPrice.create(sol_prices_array)
          end
        end
      end

      test '#historical_prices' do
        vcr_cassette(@namespace, __method__) do
          datetime = DateTime.new(2021,9,19)
          response = @wrapper.historical_price(date: datetime.strftime("%d-%m-%Y"))

          expected_result = {
            exchange: SolPrice.exchanges[:coin_gecko],
            currency: SolPrice.currencies[:usd],
            average_price: 170.10982401213687,
            datetime_from_exchange: datetime,
            volume: 5288896343.368672
          }

          result = historical_price(response, datetime: datetime)

          assert_equal expected_result, result.first
        end
      end

      test '#prices_from_ohlc 1 day' do
        vcr_cassette(@namespace, __method__) do
          response = @wrapper.ohlc(days: '1')        
          sol_prices_array = prices_from_ohlc(response)
          assert_equal 49, sol_prices_array.size
        end
      end

      test '#volume_from_daily_historical_price' do
        vcr_cassette(@namespace, __method__) do
          expected = [
            5245858966.571948,
            16149087501.300968,
            13505195046.862394
          ]
          
          response = @wrapper.daily_historical_price(days: '2')
          parsed = volume_from_daily_historical_price(response)
          
          assert_equal expected, parsed.map { |e| e[:volume] }
        end
      end
    end
  end
end
