# frozen_string_literal: true

module Api
  module V1
    class PingThingStatsController < BaseController

      RECORDS_COUNT = 60

      def index
        stats = PingThingStat.where(
          network: stats_params[:network],
          interval: stats_params[:interval].to_i
        ).last(RECORDS_COUNT)

        render json: create_json_result(stats), status: :ok
      end

      private

      def stats_params
        params.permit(:interval, :network)
      end

      def create_json_result(stats)
        return {} if stats.blank?
        
        stats.map { |el| el.to_builder.attributes! }
      end
    end
  end
end
