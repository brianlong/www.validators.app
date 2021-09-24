class SolPricesController < ApplicationController
  def index
    @coin_gecko_prices = SolPrice.where(exchange: SolPrice.exchanges[:coin_gecko])
    @ftx_prices = SolPrice.where(exchange: SolPrice.exchanges[:ftx])

    @coin_gecko_labels = @coin_gecko_prices.pluck(:datetime_from_exchange).map do |datetime|
      datetime.to_date.to_s
    end
    @coin_gecko_data = @coin_gecko_prices.pluck(:average_price)

    @ftx_data = @ftx_prices.map do |ftx_price|
      {
        x: ftx_price.datetime_from_exchange.to_datetime.strftime('%Q'),
        o: ftx_price.open,
        h: ftx_price.high,
        l: ftx_price.low,
        c: ftx_price.close
      }
    end.last(100) # This is number of records that is displayed fine on the chart.
  end
end
