# frozen_string_literal: true

module Api
  module V1
    # Commission changes API controller
    class CommissionHistoriesController < BaseController
      # /api/v1/commission-changes/:network
      def index
        ch_query = CommissionHistoryQuery.new(
          network: index_params[:network],
          time_to: index_params[:date_to],
          time_from: index_params[:date_from]
        )

        commission_histories = if index_params[:query]
          ch_query.by_query(index_params[:query])
        else
          ch_query.all_records
        end

        render json: commission_histories.as_json(except: [:validator_id]),
               status: :ok
      rescue ArgumentError => e
        render json: { error: e.message }, status: 400
      end

      private

      def index_params
        params.permit(:date_from, :date_to, :network, :query)
      end
    end
  end
end
