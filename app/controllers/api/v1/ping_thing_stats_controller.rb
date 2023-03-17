# frozen_string_literal: true

module Api
  module V1
    class PingThingStatsController < BaseController
      include CsvHelper

      RECORDS_COUNT = 60

      def index
        stats = PingThingStat.where(
          network: stats_params[:network],
          interval: stats_params[:interval].to_i
        ).last(RECORDS_COUNT)

        json_result = create_json_result(stats)
        
        respond_to do |format|
          format.json { render json: json_result, status: :ok }
          format.csv do
            send_data convert_to_csv(index_csv_headers, json_result),
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

      def create_json_result(stats)
        return {} if stats.blank?
        
        stats.map { |el| el.to_builder.attributes! }
      end
    end
  end
end
