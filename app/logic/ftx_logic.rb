module FtxLogic
  include SolPrices::Parsers::Ftx

  def get_prices_from_days
    lambda do |p|
      response = p.payload[:client].historical_price(
        resolution: p.payload[:resolution],
        start_time: p.payload[:start_time],
        end_time: p.payload[:end_time]
      )
      prices = prices_from_historical_prices(response)

      Pipeline.new(200, p.payload.merge(prices_from_exchange: prices))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from get_prices_from_days', e)
    end
  end

  def save_sol_prices
    lambda do |p|
      p.payload[:prices_from_exchange].each do |sol_price|
        datetime_from_exchange = sol_price[:datetime_from_exchange]
        SolPrice.where(
          exchange: SolPrice.exchanges[:ftx],
          datetime_from_exchange: datetime_from_exchange
        ).first_or_create(sol_price)
      end
              
      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from save_sol_prices', e)
    end
  end
end
