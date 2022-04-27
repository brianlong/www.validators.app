# frozen_string_literal: true

require "test_helper"

module ApiClients
  class FtxClientTest < ActiveSupport::TestCase
    include VcrHelper

    setup do
      @subject = FtxClient.new
      @namespace = File.join("api_clients", "ftx_client_test")
    end

    test "#get_markets" do
      vcr_cassette(@namespace, __method__) do
        response = @subject.get_markets
        expected_result = {
          "name"=>"SOL/USD", 
          "enabled"=>true, 
          "postOnly"=>false, 
          "priceIncrement"=>0.0025, 
          "sizeIncrement"=>0.01, 
          "minProvideSize"=>0.01, 
          "last"=>132.945, 
          "bid"=>132.9275, 
          "ask"=>132.94, 
          "price"=>132.94, 
          "type"=>"spot", 
          "baseCurrency"=>"SOL", 
          "quoteCurrency"=>"USD", 
          "underlying"=>nil, 
          "restricted"=>false, 
          "highLeverageFeeExempt"=>true, 
          "largeOrderThreshold"=>5000.0, 
          "change1h"=>0.022143626018760573, 
          "change24h"=>0.02342231374737774, 
          "changeBod"=>0.004154392325704358, 
          "quoteVolume24h"=>111773446.3951, 
          "volumeUsd24h"=>111773446.3951, 
          "priceHigh24h"=>136.625, 
          "priceLow24h"=>125.86
        }

        parsed_body = JSON.parse(response.body)
        assert_equal 832, parsed_body["result"].size
        assert_equal expected_result, parsed_body["result"].select { |r| r["name"] == ("SOL/USD") }.first
      end
    end

    test "#get_market" do
      vcr_cassette(@namespace, __method__) do
        response = @subject.get_market
        expected_response = {
          "name"=>"SOL/USD", 
          "enabled"=>true, 
          "postOnly"=>false, 
          "priceIncrement"=>0.0025, 
          "sizeIncrement"=>0.01, 
          "minProvideSize"=>0.01, 
          "last"=>132.9325, 
          "bid"=>132.89, 
          "ask"=>132.925, 
          "price"=>132.925, 
          "type"=>"spot", 
          "baseCurrency"=>"SOL", 
          "quoteCurrency"=>"USD", 
          "underlying"=>nil, 
          "restricted"=>false, 
          "highLeverageFeeExempt"=>true, 
          "largeOrderThreshold"=>5000.0, 
          "change1h"=>0.022028294633246195, 
          "change24h"=>0.023306838083873824, 
          "changeBod"=>0.0040410907168215125, 
          "quoteVolume24h"=>111773446.3951, 
          "volumeUsd24h"=>111773446.3951, 
          "priceHigh24h"=>136.625, 
          "priceLow24h"=>125.86
        }

        parsed_body = JSON.parse(response.body)
        assert_equal expected_response, parsed_body["result"]
      end
    end

    test "#historical_price" do
      vcr_cassette(@namespace, __method__) do
        # without params returns data for yesterday for every hour
        start_time = DateTime.new(2021,9,7)
        end_time = start_time + 3.days
        response = @subject.historical_price(
          start_time: start_time,
          resolution: 86400
        )

        parsed_body = JSON.parse(response.body)

        expected_response = {
          "startTime"=>"2021-09-07T00:00:00+00:00",
          "time"=>1630972800000.0,
          "open"=>164.26,
          "high"=>195.0,
          "low"=>124.15,
          "close"=>173.515,
          "volume"=>744961809.184675
          }
        assert_equal 211, parsed_body["result"].size
        assert_equal expected_response, parsed_body["result"].first
      end
    end
  end
end
