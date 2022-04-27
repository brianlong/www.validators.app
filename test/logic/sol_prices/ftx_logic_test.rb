# frozen_string_literal: true
require "test_helper"

# CoinGeckoLogicTest
class SolPrices::FtxLogicTest < ActiveSupport::TestCase
  include FtxLogic
  include VcrHelper

  def setup
    # Create our initial payload with the input values
    @initial_payload = {
      client: FtxClient.new,
      start_time: DateTime.new(2021,9,8),
      resolution: 86400,
    }
    @namespace = File.join("logic", "ftx_logic")
    @vcr_name = "ftx_logic"
  end

  test "#get_historical_prices" do
    vcr_cassette(@namespace, @vcr_name) do
      p = Pipeline.new(200, @initial_payload)
                  .then(&get_historical_prices)

      assert_not_nil p.payload[:prices_from_exchange]
      assert_equal 3, p.payload[:prices_from_exchange].size

    end
  end
end
