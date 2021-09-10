module SolPrices
  module Parsers
    module Ftx
      def prices_from_historical_prices(response)
        result = JSON.parse(response.body)['result']

        result.map do |row|
          datetime = convert_to_datetime_utc(row['time'])
          open_price = row['open']
          high_price = row['high']
          low_price = row['low']
          close_price = row['close']
          volume = row['volume']

          {
            exchange: SolPrice.exchanges[:ftx],
            currency: SolPrice.currencies[:usd],
            open: open_price,
            high: high_price,
            low: low_price,
            close: close_price,
            datetime_from_exchange: datetime
          }
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
