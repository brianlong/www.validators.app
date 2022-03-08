# frozen_string_literal: true

module Api
  module V1
    class SolPricesController < BaseController
      EXCHANGES = %w(coin_gecko ftx).freeze
      def index
        from = (index_params[:from] || 30.days.ago).to_datetime
        to = (index_params[:to] || from + 30.days).to_datetime

        exchange_filter = EXCHANGES.include?(index_params[:exchange]) ? index_params[:exchange] : EXCHANGES

        sol_prices = SolPrice.order(datetime_from_exchange: :asc)
                              .where(
                                datetime_from_exchange: from..to,
                                exchange: exchange_filter
                              )

        render json: sol_prices
      end

      private

      def index_params
        params.permit(:from, :to, :exchange)
      end
    end
  end
end
