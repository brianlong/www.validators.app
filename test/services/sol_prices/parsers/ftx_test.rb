require 'test_helper'

module SolPrices
  module Parsers
    class FtxTest < ActiveSupport::TestCase
      include VcrHelper
      include Parsers::Ftx

      setup do
        @namespace = File.join('services', 'sol_prices', 'parsers', 'coin_gecko')
        @wrapper = ApiWrappers::Ftx.new
      end

      test '#prices_from_historical_prices' do
        vcr_cassette(@namespace, __method__) do
          response = @wrapper.historical_price(
            start_time: DateTime.new(2021,9,8),
            resolution: 86400
          )

          sol_prices_array = prices_from_historical_prices(response)

          assert_equal 3, sol_prices_array.size

          assert_difference 'SolPrice.count', 3 do
            SolPrice.create(sol_prices_array)
          end
        end
      end
    end
  end
end
