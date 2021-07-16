# frozen_string_literal: true

# curl -H "Token: secret-api-token" https://localhost:3000/api/v1/validators/:network
require 'appsignal'

module Api
  module V1
    # This is the V1 API controller.
    class CommissionHistoriesController < BaseController
      def index
        time_r = time_rage(
          date_from: index_params[:date_from],
          date_to: index_params[:date_to]
        )
        @commissionHistories = CommissionHistory.where(created_at: time_r)
                                                .where(network: index_params[:network])
      end

      private

      def index_params
        params.permit(:date_from, :date_to, :network)
      end

      def time_range(date_from: , date_to:)
        date_from ||= 30.days.ago
        date_to ||= DateTime.now

        date_from..date_to
      end
    end
  end
end