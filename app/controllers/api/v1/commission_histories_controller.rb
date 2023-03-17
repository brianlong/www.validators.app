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
          time_from: index_params[:date_from],
          sort_by: index_params[:sort_by]
        )

        commission_histories = if index_params[:query]
          ch_query.by_query(index_params[:query])
        else
          ch_query.all_records
        end

        total_count = commission_histories.size
        commission_histories = commission_histories.page(index_params[:page])
                                                   .per(index_params[:per])
        respond_to do |format|
          format.json do
            render json: {
              commission_histories: commission_histories.as_json(except: [:validator_id]),
              total_count: total_count
            },
            status: :ok
          end
          format.csv do
            send_data convert_to_csv(index_csv_headers, commission_histories.as_json(except: [:validator_id])),
                      filename: "commission-changes-#{DateTime.now.strftime("%d%m%Y%H%M")}.csv"
          end
        end

      rescue ArgumentError => e
        render json: { error: e.message }, status: 400
      end

      private

      def index_csv_headers
        CommissionHistory.column_names.reject { |c| ["id", "validator_id", "updated_at"].include? c }
      end

      def index_params
        params.permit(:date_from, :date_to, :network, :query, :page, :per, :sort_by)
      end
    end
  end
end
