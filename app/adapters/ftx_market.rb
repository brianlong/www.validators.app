# frozen_string_literal: true

require 'uri'
require 'net/http'
# TODO: docs

module Adapters
  class FTXMarket
    BASE_CURRENCY = 'usd'
    API_URL = 'https://ftx.com/api/'
    API_KEY = Rails.application.credentials.dig(:ftx_market, :api_key)
    API_SECRET = Rails.application.credentials.dig(:ftx_market, :api_secret)
    FTX_MARKETS = { 'solana': 'SOL/USD' }.freeze
    private_constants =
      %i[BASE_CURRENCY API_URL API_KEY API_SECRET FTX_MARKETS]
    private_constants.each do |constant|
      private_constant constant
    end

    attr_reader :coin

    def initialize(coin = 'solana')
      raise 'Coin Not Supported' unless coin.in? %w[solana]

      @coin = coin.to_sym
      @market = FTX_MARKETS[@coin]
    end

    def self.api_call(endpoint = '')
      url = URI("#{API_URL}#{endpoint}")
      puts url
      req = prepare_request(url)
      res = http_get(url, req)
      JSON.parse(res.body)
    end

    def self.list_coins
      api_call('markets')
    end

    def current_price
      res = self.class.api_call("markets/#{@market}")
      res.dig('result', 'price')
    end

    def price_for_date(date)
      query = {
        resolution: 3600,
        start_time: date.beginning_of_day.to_i,
        end_time: date.end_of_day.to_i
      }.to_param
      res = self.class.api_call("markets/#{@market}/candles?#{query}")
      res.dig['result']
    end

    def price_for_range(from:, to:)
      query = {
        resolution: 3600,
        start_time: from.beginning_of_day.to_i,
        end_time: to.beginning_of_day.to_i
      }.to_param
      res = self.class.api_call("markets/#{@market}/candles?#{query}")
      res.dig['result']
    end

    private

    def self.prepare_request(url)
      timestamp = Time.now.to_i * 1000
      signature = "#{timestamp}GET#{url}"
      hmac = OpenSSL::HMAC.hexdigest('SHA256', API_SECRET, signature)

      req = Net::HTTP::Get.new(url)
      req['FTX-KEY'] = API_KEY
      req['FTX-SIGN'] = hmac
      req['FTX-TS'] = timestamp.to_s
      req
    end

    def self.http_get(url, req)
      Net::HTTP.start(
        url.hostname,
        url.port,
        use_ssl: url.scheme == 'https'
      ) { |http| http.request(req) }
    end
  end
end
