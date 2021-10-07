class SolPricesController < ApplicationController
  respond_to :html, :js

  def index
    sol_price_count ||= SolPrice.count

    filter = case params[:filtering]
             when '7'
               7
             when '30'
               30
             when 'all'
               sol_price_count
             else
               100
             end

    @coin_gecko_prices = SolPrice.where(exchange: SolPrice.exchanges[:coin_gecko])
                                 .order(datetime_from_exchange: :asc)
    @ftx_prices = SolPrice.where(exchange: SolPrice.exchanges[:ftx])
                          .order(datetime_from_exchange: :asc)

    @coin_gecko_labels = @coin_gecko_prices.pluck(:datetime_from_exchange).last(filter).map do |datetime|
      datetime.to_date.to_s
    end
    @coin_gecko_data = @coin_gecko_prices.pluck(:average_price).last(filter)

    @ftx_data = @ftx_prices.map do |ftx_price|
      {
        x: ftx_price.datetime_from_exchange.to_datetime.strftime('%Q').to_i,
        o: ftx_price.open,
        h: ftx_price.high,
        l: ftx_price.low,
        c: ftx_price.close
      }
    end.last(filter) # This is number of records that is displayed fine on the chart.
  end
end
