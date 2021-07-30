# frozen_string_literal: true

module Api
  module V1
    # Commission changes API controller
    class CommissionHistoriesController < BaseController
      # /api/v1/commission-changes/:network
      def index
        time_r = time_range(
          date_from: index_params[:date_from],
          date_to: index_params[:date_to]
        )

        @commission_histories = CommissionHistoryQuery.new(
          network: index_params[:network],
          query: index_params[:query],
          time_range: time_r
        ).call

        render json: @commission_histories.as_json(except: [:validator_id]),
               status: :ok
      rescue ArgumentError => e
        render json: {error: e.message}, status: 400
      end

      private

      def index_params
        params.permit(:date_from, :date_to, :network, :query)
      end

      # Set default time range or format range from params
      def time_range(date_from:, date_to:)
        date_from ||= 30.days.ago
        date_to ||= DateTime.now

        date_from.to_datetime..date_to.to_datetime
      end
    end
  end
end
