# frozen_string_literal: true

require "uri"
require "net/http"

# https://www.coingecko.com/pl/api/documentation
# https://github.com/julianfssen/coingecko_ruby
class CoinGeckoClient
  attr_reader :coin

  def initialize(
    api_client: CoingeckoRuby::Client.new,
    coin: "solana",
    currency: "usd"
  )
    raise "Coin Not Supported" unless coin.in? %w[solana]

    @api_client = api_client
    @coin = coin
    @currency = currency
  end

  # Fetches CoinGecko"s API status.
  def status
    @api_client.status
  end

  # Fetches the current price for a coin in the given coin or currency.
  def price(ids = @coin)
    @api_client.price(ids, include_24hr_vol: true, include_24hr_change: true)
  end

  # ohlc - open, high, low, close
  def ohlc(days: 1)
    # count must be one of: 1/7/14/30/90/180/365/max
    available_days = %w[1 7 14 30 90 180 365 max]
    unless days.to_s.in? available_days
      raise ArgumentError, "Count must be one of #{available_days.join("/")}"
    end

    # resolution depends on count:
    # 1 - 2 days: 30 minutes
    # 3 - 30 days: 4 hours
    # 31 and before: 4 days

    @api_client.ohlc(@coin, currency: @currency, days: days.to_s)
  end

  # Get historical data (name, price, market, stats) at a given date for a coin
  def historical_price(date: Date.yesterday)
    @api_client.historical_price(
      @coin,
      currency: @currency,
      date: date
    )
  end

  # Get historical market data include price, market cap, and 24h volume (granularity auto)
  # Minutely data will be used for duration within 1 day,
  # Hourly data will be used for duration between 1 day and 90 days,
  # Daily data will be used for duration above 90 days.
  def daily_historical_price(days: 1)
    @api_client.daily_historical_price(
      @coin,
      currency: @currency,
      days: days
    )
  end
end
