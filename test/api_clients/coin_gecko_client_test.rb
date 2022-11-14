# frozen_string_literal: true

require "test_helper"

module ApiClients
  class CoinGeckoClientTest < ActiveSupport::TestCase
    include VcrHelper

    setup do
      @subject = CoinGeckoClient.new
      @namespace = File.join("api_clients", "coin_gecko_client_test")
    end

    test "#status" do
      vcr_cassette(@namespace, __method__) do
        expected_response = {"gecko_says"=>"(V3) To the Moon!"}
        response = @subject.status
        assert_equal expected_response, response
      end
    end

    test "#price" do
      vcr_cassette(@namespace, __method__) do
        expected_response = {"solana"=>{"usd"=>14.53, "usd_24h_vol"=>1160562245.3673658, "usd_24h_change"=>6.3289427662734985}}
        response = @subject.price

        assert_equal expected_response, response
      end
    end

    test "#ohlc" do
      vcr_cassette(@namespace, __method__) do
        expected_response = [1630323000000, 101.23, 101.23, 100.73, 100.73] # [UNIX timestamp for OHLC data, open, high, low, close]
        response = @subject.ohlc

        assert_equal expected_response, response[0]
      end
    end

    test "#historical_price" do
      vcr_cassette(@namespace, __method__) do
        date = Date.new(2021,9,19).strftime("%d-%m-%Y")
        response = @subject.historical_price(date: date)

        assert_equal 170.10982401213687, response.dig("market_data", "current_price", "usd")
        assert_equal 50565779823.43124, response.dig("market_data", "market_cap", "usd")
        assert_equal 5288896343.368672, response.dig("market_data", "total_volume", "usd")
      end
    end

    test "#daily_historical_price" do
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
end
