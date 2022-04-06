module Api
  module V1
    class PingThingStatsController < BaseController
      def index
        stats = PingThingStat.where(
          network: stats_params[:network],
          interval: stats_params[:interval].to_i
        ).last(60)

        render json: stats, status: :ok
      end

      private

      def stats_params
        params.permit(:interval, :network)
      end
    end
  end
end
