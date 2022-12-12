# frozen_string_literal: true

module Api
  module V1
    class SolPricesController < BaseController
      def index
        days_size = index_params[:filtering]
        from = (index_params[:from] || 30.days.ago).to_datetime.beginning_of_day
        to = (index_params[:to] || DateTime.now).to_datetime.end_of_day

        sol_prices = SolPrice.where.not(average_price: nil)
                             .order(datetime_from_exchange: :asc)

        response =
          if index_params[:filtering].presence
            sol_prices.last(days_size.to_i).map do |coin_gecko_price|
              {
                x: coin_gecko_price.datetime_from_exchange.strftime("%b %d"),
                y: coin_gecko_price.average_price.round(2)
              }
            end
          else
            sol_prices.where(datetime_from_exchange: from..to)
          end

        render json: response, status: :ok
      end

      private

      def index_params
        params.permit(:from, :to, :filtering)
      end
    end
  end
end
