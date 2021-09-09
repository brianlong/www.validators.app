module SolPrices
  module Parsers
    module CoinGecko
      def prices_from_ohlc(response)
        response.map do |row|
          datetime = convert_to_datetime_utc(row[0])
          open_price = row[1]
          high_price = row[2]
          low_price = row[3]
          close_price = row[4]

          {
            exchange: SolPrice.exchanges[:coingecko],
            currency: SolPrice.currencies[:usd],
            open: open_price,
            high: high_price,
            low: low_price,
            close: close_price,
            datetime_from_exchange: datetime
          }
        end
      end

      # For getting volume from coingecko.
      def volume_from_daily_historical_price(response)
        volumes = response['total_volumes']

        volumes.map do |volume|
          datetime = convert_to_datetime_utc(volume[0])

          { datetime: datetime, volume: volume[1] }
        end
      end

      def find_price_for_date(prices, date)
        prices.find do |price|
          price[:datetime_from_exchange] == date
        end
      end
    
      def find_volume_from_beginning_of_day(volumes, date)
        volumes.find do |volume| 
          volume[:datetime] == date
        end
      end

      # Convert timestamp to datetime
      def convert_to_datetime_utc(timestamp)
        timestamp = timestamp / 1000 # removes miliseconds 
        Time.at(timestamp).utc.to_datetime
      end
    end
  end
end
