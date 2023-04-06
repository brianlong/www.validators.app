module SolPrices::CoinGeckoLogic
  include SolPrices::Parsers::CoinGecko
  class IncompleteDataError < StandardError; end

  # Fetches historical price data for a coin at a given date.
  # Adds to payload an array with one price for given date.
  def get_historical_average_price
    retry_count ||= 1
    lambda do |p|
      datetime = p.payload[:datetime]

      response = p.payload[:client].historical_price(date: datetime.strftime("%d-%m-%Y"))
      price = historical_price_to_sol_price_hash(response, datetime: datetime)

      raise IncompleteDataError if price[0][:volume].blank? || price[0][:average_price].blank?
      Pipeline.new(200, p.payload.merge(prices_from_exchange: price))
    rescue IncompleteDataError => e
      if (retry_count += 1) < 5
        sleep(5 * retry_count)
        retry
      else
        Pipeline.new(500, p.payload, "Error from get_historical_average_price", e)
      end
    rescue StandardError => e
      puts e
      Pipeline.new(500, p.payload, 'Error from get_historical_average_price', e)
    end
  end

  # Fetches a coin's historical price data in daily ranges.
  # Includes volume
  # Adds to payload an array with prices from range.
  def get_daily_historical_average_price(days: 'max')
    lambda do |p|
      prices = []
      response = p.payload[:client].daily_historical_price(days: days)
      response['prices'].each_with_index do |price, i|
        volume = response['total_volumes'][i]

        prices << daily_historical_price_to_sol_price_hash(price, volume)
      end

      Pipeline.new(200, p.payload.merge(prices_from_exchange: prices))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from get_daily_historical_average_price', e)
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
      prices = prices_from_ohlc_to_sol_price_hash(response)

      Pipeline.new(200, p.payload.merge(prices_from_exchange: prices))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from get_ohlc_prices', e)
    end
  end
end
