# frozen_string_literal: true

module Api
  module V1
    class PingThingFeeStatsController < BaseController
      CREATED_AT_LIMIT = 24

      def index
        stats = PingThingFeeStat.where(
          network: stats_params[:network],
        )
        .where(
          "created_at >= ?", Time.zone.now - CREATED_AT_LIMIT.hours
        )

        results = {}
        stats.pluck(:pinger_region).uniq.each do |region|
          results[region] = {}
          stats.where(pinger_region: region).pluck(:priority_fee_percentile).uniq.each do |fee|
            results[region][fee] = stats.where(priority_fee_percentile: fee, pinger_region: region).as_json
          end
        end

        respond_to do |format|
          format.json { render json: results.as_json, status: :ok }
          format.csv do
            send_data convert_to_csv(index_csv_headers, results),
                      filename: "ping-thing-stats-#{DateTime.now.strftime("%d%m%Y%H%M")}.csv"
          end
        end
      end

      private

      def index_csv_headers
        PingThingStat::FIELDS_FOR_API.map(&:to_s)
      end

      def stats_params
        params.permit(:interval, :network)
      end
    end
  end
end
