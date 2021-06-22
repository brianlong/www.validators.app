# frozen_string_literal: true

require 'uri'
require 'net/http'
# TODO: docs

module Adapters
  class CoinGecko
    BASE_CURRENCY = 'usd'
    private_constant :BASE_CURRENCY

    API_URL = 'https://api.coingecko.com/api/v3/'
    private_constant :API_URL

    attr_reader :coin

    def initialize(coin = 'solana')
      raise 'Coin Not Supported' unless coin.in? %w[solana]

      @coin = coin
    end

    def self.api_call(endpoint = 'coins')
      url = URI("#{API_URL}#{endpoint}")
      puts url
      res = Net::HTTP.get_response(url)
      JSON.parse(res.body)
    end

    def self.list_coins
      api_call('coins/list?include_platform=false')
    end

    def self.ping
      api_call('ping')
    end

    def current_price
      query = { ids: coin }.merge(default_options).to_query

      res = self.class.api_call("simple/price?#{query}")
      res.dig(coin, 'usd')
    end

    def price_for_date(date)
      date = date.strftime('%d-%m-%Y')
      options = default_options
      query = { date: date }.merge(options).to_query

      res = self.class.api_call("coins/#{coin}/history?#{query}")
      res.dig('market_data', 'current_price', 'usd')
    end

    def prices_for_range(from:, to:)
      # Convert dates to UNIX timestamp
      from = from.to_time.to_i
      to = to.to_time.to_i
      options = default_options.slice(:vs_currency)
      query = { from: from, to: to }.merge(options).to_query

      res =
        self.class.api_call("coins/#{coin}/market_chart/range?#{query}")
      res[:prices]
    end

    private

    def default_options
      {
        localization: 'false',
        market_data: 'false',
        market_caps: 'false',
        total_volumes: 'false',
        community_data: 'false',
        developer_data: 'false',
        include_platform: 'false',
        vs_currency: BASE_CURRENCY
      }
    end
  end
end
