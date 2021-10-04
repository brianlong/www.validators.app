class SolPricesController < ApplicationController
  def index
    @coin_gecko_prices = SolPrice.where(exchange: SolPrice.exchanges[:coin_gecko])
                                 .order(datetime_from_exchange: :asc)
    @ftx_prices = SolPrice.where(exchange: SolPrice.exchanges[:ftx])
                          .order(datetime_from_exchange: :asc)

    @coin_gecko_labels = @coin_gecko_prices.pluck(:datetime_from_exchange).last(100).map do |datetime|
      datetime.to_date.to_s
    end
    @coin_gecko_data = @coin_gecko_prices.pluck(:average_price).last(100)

    @ftx_data = @ftx_prices.map do |ftx_price|
      {
        x: ftx_price.datetime_from_exchange.to_datetime.strftime('%Q').to_i,
        o: ftx_price.open,
        h: ftx_price.high,
        l: ftx_price.low,
        c: ftx_price.close
      }
    end.last(100) # This is number of records that is displayed fine on the chart.
  end
end
