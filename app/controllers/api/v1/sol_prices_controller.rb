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

        result =
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

        respond_to do |format|
          format.json { render json: result, status: :ok }
          format.csv do
            if index_params[:filtering].presence
              render json: { "status" => "filtering option not available for csv format" }, status: 405
            else
              send_data convert_to_csv(index_csv_headers, result.as_json),
                        filename: "sol-prices-#{DateTime.now.strftime("%d%m%Y%H%M")}.csv"
            end
          end
        end
      end

      private

      def index_csv_headers
        SolPrice::API_FIELDS.map(&:to_s)
      end

      def index_params
        params.permit(:from, :to, :filtering)
      end
    end
  end
end
