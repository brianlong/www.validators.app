class SolPricesController < ApplicationController
  respond_to :html, :js

  def index
    filter = params[:filtering].to_i
    sol_price_count ||= SolPrice.count

    coin_gecko_prices = SolPrice.where(exchange: SolPrice.exchanges[:coin_gecko])
                                .where.not(average_price: nil)
                                .order(datetime_from_exchange: :asc)
                                .last(filter)

    @coin_gecko_data = coin_gecko_prices.map do |coin_gecko_price|
      {
        x: coin_gecko_price.datetime_from_exchange.strftime("%b %d"),
        y: coin_gecko_price.average_price.round(2)
      }
    end
  end
end
