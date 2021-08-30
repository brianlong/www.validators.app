# frozen_string_literal: true

require 'test_helper'

class SolPrices::ApiWrappers::CoinGeckoTest < ActiveSupport::TestCase
  include VcrHelper

  setup do
    @subject = SolPrices::ApiWrappers::CoinGecko.new
    @namespace = File.join('services', 'api_wrappers', 'coin_gecko')
  end

  test '#coins_list' do
    vcr_cassette(@namespace, __method__) do
      response = @subject.coins_list
      assert_equal 9252, response.size
    end
  end

  test '#status' do
    vcr_cassette(@namespace, __method__) do
      expected_response = {"gecko_says"=>"(V3) To the Moon!"}
      response = @subject.status
      assert_equal expected_response, response
    end
  end

  test '#price' do
    vcr_cassette(@namespace, __method__) do
      expected_response = { "solana"=>{ "usd"=>144.23 } }
      response = @subject.price

      assert_equal expected_response, response
    end
  end

  test '#ohlc' do
    vcr_cassette(@namespace, __method__) do
      expected_response = [1630323000000, 101.23, 101.23, 100.73, 100.73] # [UNIX timestamp for OHLC data, open, high, low, close]
      response = @subject.ohlc

      assert_equal expected_response, response[0]
    end
  end

  test '#daily_historical_price' do
    vcr_cassette(@namespace, __method__) do
      expected_response = {
        "prices"=>[[1630368000000, 109.6467328393857], [1630408428000, 120.24526178067454]],
        "market_caps"=>[[1630368000000, 31920673369.62922], [1630408428000, 35122889644.84562]],
        "total_volumes"=>[[1630368000000, 4827155957.583222], [1630408428000, 5559612386.704307]]
      }
      response = @subject.daily_historical_price

      assert_equal expected_response, response
    end
  end
end
