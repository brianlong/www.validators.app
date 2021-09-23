module SolPrices::CoinGeckoLogic
  include SolPrices::Parsers::CoinGecko

  def get_historical_average_price
    lambda do |p|
      datetime = p.payload[:datetime]

      response = p.payload[:client].historical_price(date: datetime.strftime("%d-%m-%Y"))
      price = historical_price(response, datetime: datetime)

      Pipeline.new(200, p.payload.merge(prices_from_exchange: price))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from get_historical_average_price', e)
    end
  end

  ### Methods below can be used to get open, close, high and low price from coin gecko
  # Unfortunataely, their API returns data in weird intervals - 30 minutes, 4 hours, 4 days.
  # If they'll add new options to get data in daily intervals, methods below
  # will be useful.
  ###
  def get_ohlc_prices
    lambda do |p|
      response = p.payload[:client].ohlc(days: p.payload[:days])
      prices = prices_from_ohlc(response)

      Pipeline.new(200, p.payload.merge(prices_from_exchange: prices))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from get_ohlc_prices', e)
    end
  end

  def filter_prices_by_date
    lambda do |p|
      p.payload[:prices_from_exchange].reject! do |price|
        price[:datetime_from_exchange] != p.payload[:datetime]
      end

      Pipeline.new(200, p.payload)
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

      Pipeline.new(200, p.payload.merge(volume: volume[:volume]))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from filter_volumes_by_date', e)
    end
  end
end
