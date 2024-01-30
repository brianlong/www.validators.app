# frozen_string_literal: true

module Api
  module V1
    class PingThingUserStatsController < BaseController
      def last
        last_5_mins = PingThingUserStat.where(
          network: stats_params[:network],
          interval: 5
        ).group_by(&:username)
        last_60_mins = PingThingUserStat.where(
          network: stats_params[:network],
          interval: 60
        ).group_by(&:username)


        render json: {
          last_5_mins: last_5_mins.to_json,
          last_60_mins: last_60_mins.to_json,
        }, status: :ok
      end

      private

      def stats_params
        params.permit(:network)
      end
    end
  end
end
