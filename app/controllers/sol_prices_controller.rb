class SolPricesController < ApplicationController
  def index
    @coin_gecko_prices = SolPrice.where(exchange: SolPrice.exchanges[:coin_gecko])
    @ftx_prices = SolPrice.where(exchange: SolPrice.exchanges[:ftx])
  end
end
