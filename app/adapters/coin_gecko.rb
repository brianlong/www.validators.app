# frozen_string_literal: true

require 'uri'
require 'net/http'
# TODO: docs


class CoinGecko
  BASE_CURRENCY = 'usd'
  private_constant :BASE_CURRENCY

  API_URL = Rails.application.credentials.dig(:coin_gecko, :api_url)
  private_constant :API_URL

  attr_reader :coin

  def initialize(coin = 'solana')
    raise 'Coin Not Supported' unless coin.in? %w[solana]

    @coin = coin
  end

  def self.api_call(endpoint)
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

  def price_for_last_days(count = '1')
    # count must be one of: 1/7/14/30/90/180/365/max
    available_counts = %w[1 7 14 30 90 180 365 max]
    unless count.to_s.in? available_counts
      raise ArgumentError, "Count must be one of #{available_counts.join('/')}"
    end
    # resolution depends on count:
    # 1 - 2 days: 30 minutes
    # 3 - 30 days: 4 hours
    # 31 and before: 4 days

    options = default_options.slice(:vs_currency)
    query = { days: count }.merge(options).to_query

    self.class.api_call("coins/#{coin}/ohlc?#{query}")
  end

  def price_for_date(date)
    from = date.beginning_of_day.to_i
    to = date.end_of_day.to_i
    options = default_options
    query = { from: from, to: to }.merge(options).to_query

    res = self.class.api_call("coins/#{coin}/market_chart/range?#{query}")
    res.dig('market_data', 'current_price', 'usd')
    res
  end

  def price_for_range(from:, to:)
    # Convert dates to UNIX timestamp
    from = from.to_time.to_i
    to = to.to_time.to_i
    options = default_options.slice(:vs_currency)
    query = { from: from, to: to }.merge(options).to_query

    res =
      self.class.api_call("coins/#{coin}/market_chart/range?#{query}")
    res[:prices]
  end

  def price_for_yesterday
    price_for_last_days
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

