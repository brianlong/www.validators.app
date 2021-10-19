module SolPrices::FtxLogic
  include SolPrices::Parsers::Ftx

  def get_historical_prices
    lambda do |p|
      response = p.payload[:client].historical_price(
        resolution: p.payload[:resolution],
        start_time: p.payload[:start_time],
        end_time: p.payload[:end_time]
      )

      prices = prices_from_historical_prices(response)

      Pipeline.new(200, p.payload.merge(prices_from_exchange: prices))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from get_historical_prices', e)
    end
  end
end
