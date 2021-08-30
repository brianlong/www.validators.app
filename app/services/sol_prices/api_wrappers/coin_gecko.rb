# frozen_string_literal: true

require 'uri'
require 'net/http'
# TODO: docs
module SolPrices
  module ApiWrappers
    # https://www.coingecko.com/pl/api/documentation
    # https://github.com/julianfssen/coingecko_ruby
    class CoinGecko
      attr_reader :coin

      def initialize(
        api_client: CoingeckoRuby::Client.new, 
        coin: 'solana',
        currency: 'usd'
      )
        raise 'Coin Not Supported' unless coin.in? %w[solana]

        @api_client = api_client
        @coin = coin
        @currency = currency
      end

      def coins_list
        @api_client.coins_list
      end

      def status
        @api_client.status
      end

      def price(ids = @coin)
        ids = ids
        res = @api_client.price(ids)
      end

      # ohlc - open, high, low, close
      def ohlc(days: '1')
        # count must be one of: 1/7/14/30/90/180/365/max
        available_days = %w[1 7 14 30 90 180 365 max]
        unless days.to_s.in? available_days
          raise ArgumentError, "Count must be one of #{available_days.join('/')}"
        end
        # resolution depends on count:
        # 1 - 2 days: 30 minutes
        # 3 - 30 days: 4 hours
        # 31 and before: 4 days

        @api_client.ohlc(@coin, currency: @currency, days: days)
      end

      def daily_historical_price(days: '1')
        @api_client.daily_historical_price(
          @coin, 
          currency: @currency, 
          days: days
        )
      end

      def price_for_range(from:, to:)
        # Convert dates to UNIX timestamp
        from = from.to_time.to_i
        to = to.to_time.to_i
        options = default_options.slice(:vs_currency)
        query = { from: from, to: to }.merge(options).to_query

        @api_client.send_request(endpoint)
      end
    end
  end
end
