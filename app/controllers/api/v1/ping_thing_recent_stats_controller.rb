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
          last_5_mins: {
            min: last_5_mins&.min,
            max: last_5_mins&.max,
            p90: last_5_mins&.p90,
            median: last_5_mins&.median,
            num_of_records: last_5_mins&.num_of_records
          },
          last_60_mins: {
            min: last_60_mins&.min,
            max: last_60_mins&.max,
            p90: last_60_mins&.p90,
            median: last_60_mins&.median,
            num_of_records: last_60_mins&.num_of_records
          },
        }, status: :ok
      end

      private

      def stats_params
        params.permit(:network)
      end
    end
  end
end
