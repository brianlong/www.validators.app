# frozen_string_literal: true

module Api
  module V1
    class HistoricalSolPricesController < BaseController
      def index
        filter = index_params[:filtering].to_i
        coin_gecko_prices = SolPrice.where(exchange: SolPrice.exchanges[:coin_gecko])
                                    .where.not(average_price: nil)
                                    .order(datetime_from_exchange: :asc)
                                    .last(filter)

        coin_gecko_data = coin_gecko_prices.map do |coin_gecko_price|
          {
            x: coin_gecko_price.datetime_from_exchange.strftime("%b %d"),
            y: coin_gecko_price.average_price.round(2)
          }
        end

        render json: coin_gecko_data
      end

      private

      def index_params
        params.permit(:filtering)
      end
    end
  end
end
