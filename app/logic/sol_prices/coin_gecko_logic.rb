module SolPrices::CoinGeckoLogic
  include SolPrices::Parsers::CoinGecko

  def get_ohlc_prices
    lambda do |p|
      response = p.payload[:client].ohlc(days: p.payload[:days])
      prices = prices_from_ohlc(response)

      Pipeline.new(200, p.payload.merge(prices_from_exchange: prices))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from get_prices_from_days', e)
    end
  end

  def filter_prices_by_date
    lambda do |p|
      sol_price = find_price_for_date(
        p.payload[:prices_from_exchange], 
        p.payload[:datetime]
      )

      Pipeline.new(200, p.payload.merge(sol_price: sol_price))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from filter_prices_by_date', e)
    end
  end

  def get_volumes_from_days
    lambda do |p|
      response = p.payload[:client].daily_historical_price(
        days: p.payload[:days]
      )

      volumes = volume_from_daily_historical_price(response)

      Pipeline.new(200, p.payload.merge(volumes: volumes))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from get_volumes_from_days', e)
    end
  end

  def filter_volumes_by_date
    lambda do |p|
      volume = find_volume_from_beginning_of_day(
        p.payload[:volumes], 
        p.payload[:datetime]
      )

      Pipeline.new(200, p.payload.merge(sol_price_volume: volume[:volume]))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from filter_volumes_by_date', e)
    end
  end

  # For one, yesterday price.
  def save_sol_price
    lambda do |p|
      p.payload[:sol_price][:volume] = p.payload[:sol_price_volume]
      p.payload[:sol_price][:epoch_testnet] = p.payload[:epoch_testnet]
      p.payload[:sol_price][:epoch_mainnet] = p.payload[:epoch_mainnet]

      datetime_from_exchange = p.payload.dig(:sol_price, :datetime_from_exchange)

      SolPrice.where(
        exchange: p.payload[:exchange],
        datetime_from_exchange: datetime_from_exchange
      ).first_or_create(p.payload[:sol_price])
              
      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from save_sol_price', e)
    end
  end
end
