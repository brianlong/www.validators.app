# frozen_string_literal: true

module Api
  module V1
    class SolPricesController < BaseController
      def index
        from = (index_params[:from] || 30.days.ago).to_datetime
        to = (index_params[:to] || from + 30.days).to_datetime

        if index_params[:exchange]
          if SolPrice::EXCHANGES.include?(index_params[:exchange])
            exchange_filter = index_params[:exchange]
          else
            response = { error: "invalid exchange" }
            response_status = :unprocessable_entity
          end
        else
          exchange_filter = SolPrice::EXCHANGES
        end

        response ||= SolPrice.order(datetime_from_exchange: :asc)
                              .where(
                                datetime_from_exchange: from..to,
                                exchange: exchange_filter
                              )
        response_status ||= :ok

        render json: response, status: response_status
      end

      private

      def index_params
        params.permit(:from, :to, :exchange)
      end
    end
  end
end
