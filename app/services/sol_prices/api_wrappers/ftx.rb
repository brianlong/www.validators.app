# frozen_string_literal: true

require 'uri'
require 'net/http'
# TODO: docs

module SolPrices
  module ApiWrappers
    # https://docs.ftx.com/#overview
    class Ftx
      API_URL = 'https://ftx.com/api'
      API_KEY = Rails.application.credentials.dig(:ftx_market, :api_key)
      API_SECRET = Rails.application.credentials.dig(:ftx_market, :api_secret)

      private_constants =
        %i[API_URL API_KEY API_SECRET]
      private_constants.each do |constant|
        private_constant constant
      end

      attr_reader :coin

      def initialize(
        api_client: SolPrices::FtxApiClient,
        coin: 'solana',
        market: 'SOL/USD'
      )
        raise 'Coin Not Supported' unless coin.in? %w[solana]

        @api_client = api_client.new(api_url: API_URL)
        @coin = coin.to_sym
        @market = market
      end

      # https://docs.ftx.com/#get-markets
      def get_markets
        endpoint = 'markets'
        request = prepare_request(endpoint)

        @api_client.send_request(request)
      end

      # https://docs.ftx.com/#get-single-market
      def get_market(market: @market)
        endpoint = "markets/#{market}"
        request = prepare_request(endpoint)

        @api_client.send_request(request)
      end

      # https://docs.ftx.com/?python#get-historical-prices
      #
      # resolution window length in seconds.
      # options: 15, 60, 300, 900, 3600, 14400, 86400, or any multiple of 86400 up to 30*86400
      def historical_price(
        market: @market,
        resolution: 86400, # 24h interval
        start_time: DateTime.new(2020,7,27), # first day when sol appeared
        end_time: nil
      )
        query = { resolution: resolution }
        query[:start_time] = start_time.beginning_of_day.to_i if start_time
        query[:end_time] = end_time.beginning_of_day.to_i if end_time
        query = query.to_param

        endpoint = "markets/#{market}/candles?#{query}"
        request = prepare_request(endpoint)

        @api_client.send_request(request)
      end

      private

      def prepare_request(endpoint)
        url = URI("#{API_URL}/#{endpoint}")

        timestamp = Time.now.to_i * 1000
        signature = "#{timestamp}GET#{url}"
        hmac = OpenSSL::HMAC.hexdigest('SHA256', API_SECRET, signature)

        req = Net::HTTP::Get.new(url)
        req['FTX-KEY'] = API_KEY
        req['FTX-SIGN'] = hmac
        req['FTX-TS'] = timestamp.to_s
        req
      end
    end
  end
end
