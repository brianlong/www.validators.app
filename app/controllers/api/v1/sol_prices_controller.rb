# frozen_string_literal: true

module Api
  module V1
    class SolPricesController < BaseController
      def index
        from = (index_params[:from] || 30.days.ago).to_datetime.beginning_of_day
        to = (index_params[:to] || DateTime.now).to_datetime.end_of_day

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

        response ||= SolPrice.where(datetime_from_exchange: from..to, exchange: exchange_filter)
                             .order(datetime_from_exchange: :asc)

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
