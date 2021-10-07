class SolPricesController < ApplicationController
  respond_to :html, :js

  def index
    @filter_days = [7, 30, 60, 90]
    filter = params[:filtering].to_i
    sol_price_count ||= SolPrice.count

    coin_gecko_prices = SolPrice.where(exchange: SolPrice.exchanges[:coin_gecko])
                                 .order(datetime_from_exchange: :asc)
                                 .last(filter)
    ftx_prices = SolPrice.where(exchange: SolPrice.exchanges[:ftx])
                          .order(datetime_from_exchange: :asc)
                          .last(filter)

    @coin_gecko_data = coin_gecko_prices.map do |coin_gecko_price|
      {
        x: coin_gecko_price.datetime_from_exchange.strftime("%b %d"),
        y: coin_gecko_price.average_price
      }
    end

    @ftx_data = ftx_prices.map do |ftx_price|
      {
        x: ftx_price.datetime_from_exchange.to_datetime.strftime('%Q').to_i,
        o: ftx_price.open,
        h: ftx_price.high,
        l: ftx_price.low,
        c: ftx_price.close
      }
    end  # This is number of records that is displayed fine on the chart.
  end
end
