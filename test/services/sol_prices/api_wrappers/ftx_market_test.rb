# frozen_string_literal: true

require 'test_helper'

class SolPrices::ApiWrappers::FtxMarketTest < ActiveSupport::TestCase
  include VcrHelper

  setup do
    @subject = SolPrices::ApiWrappers::FtxMarket.new
    @namespace = File.join('services', 'api_wrappers', 'ftx')
  end

  test '#get_markets' do
    vcr_cassette(@namespace, __method__) do
      response = @subject.get_markets
      expected_result = {
        "name"=>"SOL/USD",
        "enabled"=>true,
        "postOnly"=>false,
        "priceIncrement"=>0.0025,
        "sizeIncrement"=>0.01,
        "minProvideSize"=>0.01,
        "last"=>144.3375,
        "bid"=>144.35,
        "ask"=>144.365,
        "price"=>144.35,
        "type"=>"spot",
        "baseCurrency"=>"SOL",
        "quoteCurrency"=>"USD",
        "underlying"=>nil,
        "restricted"=>false,
        "highLeverageFeeExempt"=>true,
        "change1h"=>-0.005151708334051241,
        "change24h"=>0.024358223783419376,
        "changeBod"=>0.01635246695182271,
        "quoteVolume24h"=>130235780.650375,
        "volumeUsd24h"=>130235780.650375
      }

      parsed_body = JSON.parse(response.body)
      assert_equal 716, parsed_body['result'].size
      assert_equal expected_result, parsed_body['result'].select { |r| r['name'] == ('SOL/USD') }.first
    end
  end

  test '#get_market' do
    vcr_cassette(@namespace, __method__) do
      response = @subject.get_market
      expected_response = {
        "name"=>"SOL/USD",
        "enabled"=>true,
        "postOnly"=>false,
        "priceIncrement"=>0.0025,
        "sizeIncrement"=>0.01,
        "minProvideSize"=>0.01,
        "last"=>143.9275,
        "bid"=>143.935,
        "ask"=>144.055,
        "price"=>143.935,
        "type"=>"spot",
        "baseCurrency"=>"SOL",
        "quoteCurrency"=>"USD",
        "underlying"=>nil,
        "restricted"=>false,
        "highLeverageFeeExempt"=>true,
        "change1h"=>-0.010569007888088814,
        "change24h"=>0.026603901430048857,
        "changeBod"=>0.013430497614898524,
        "quoteVolume24h"=>131157310.1566,
        "volumeUsd24h"=>131157310.1566
      }

      parsed_body = JSON.parse(response.body)
      assert_equal expected_response, parsed_body['result']
    end
  end

  test '#historical_price' do
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
      assert_equal 4, parsed_body['result'].size
      assert_equal expected_response, parsed_body['result'].first
    end
  end
end
