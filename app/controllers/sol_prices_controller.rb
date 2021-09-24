class SolPricesController < ApplicationController
  def index
    @coin_gecko_prices = SolPrice.where(exchange: SolPrice.exchanges[:coin_gecko])
    @ftx_prices = SolPrice.where(exchange: SolPrice.exchanges[:ftx])

    @coin_gecko_labels = @coin_gecko_prices.pluck(:datetime_from_exchange).map do |datetime|
      datetime.to_date.to_s
    end
    @coin_gecko_data = @coin_gecko_prices.pluck(:average_price)
  end
end
