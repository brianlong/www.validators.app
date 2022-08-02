# frozen_string_literal: true

module Api
  module V1
    class PingThingRecentStatsController < BaseController
      def last
        last_5_mins = PingThingRecentStat.where(
          network: stats_params[:network],
          interval: 5
        ).last
        last_60_mins = PingThingRecentStat.where(
          network: stats_params[:network],
          interval: 60
        ).last

        render json: {
          last_5_mins: last_5_mins,
          last_60_mins: last_60_mins,
        }, status: :ok
      end

      private

      def stats_params
        params.permit(:network)
      end
    end
  end
end
