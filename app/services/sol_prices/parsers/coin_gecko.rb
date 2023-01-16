module SolPrices
  module Parsers
    module CoinGecko
      def prices_from_ohlc_to_sol_price_hash(response)
        response.map do |row|
          datetime = convert_to_datetime_utc(row[0])

          shared_data.merge (
            { datetime_from_exchange: datetime }
          )
        end
      end

      def historical_price_to_sol_price_hash(response, datetime:)
        price_hash = shared_data.merge({
          average_price: response.dig('market_data', 'current_price', 'usd'),
          datetime_from_exchange: datetime,
          volume: response.dig('market_data', 'total_volume', 'usd')
        })

        [price_hash]
      end

      def daily_historical_price_to_sol_price_hash(price, volume)
        # Compare timestamps
        return nil unless price[0] == volume[0]

        datetime = convert_to_datetime_utc(price[0])

        # We want to save only data from whole day.
        return nil unless datetime.to_s(:time) == '00:00'

        price = price[1]
        volume = volume[1]

        shared_data.merge({
          average_price: price,
          datetime_from_exchange: datetime,
          volume: volume
        })
      end

      def shared_data
        {
          exchange: SolPrice.exchanges[:coin_gecko],
          currency: SolPrice.currencies[:usd]
        }
      end

      # Convert timestamp to datetime
      def convert_to_datetime_utc(timestamp)
        timestamp = timestamp / 1000 # removes miliseconds
        Time.at(timestamp).utc.to_datetime
      end
    end
  end
end
