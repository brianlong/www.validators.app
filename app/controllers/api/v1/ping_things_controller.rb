# frozen_string_literal: true

module Api
  module V1
    class PingThingsController < BaseController

      class InvalidRecordCount < StandardError; end

      MAX_RECORDS = 1000
      
      def index
        limit = [(index_params[:limit] || 240).to_i, 9999].min
        page = index_params[:page] || 1
        with_stats = index_params[:with_stats].to_s == "true" ? true : false

        ping_things = PingThing.where(network: index_params[:network])
                               .includes(:user)
                               .order(reported_at: :desc)
                               .page(page)
                               .per(limit)

        json_result = ping_things.map { |pt| create_json_result(pt) }

        if with_stats
          total_count = PingThing.where(network: index_params[:network]).count
          p90 = PingThing.where(network: index_params[:network], reported_at: (DateTime.now - 5.minutes)..DateTime.now)
                         .pluck(:response_time).sort
          count_last_5_minutes = p90.count
          avg_last_5_minutes = p90.average&.round(2)
          p90 = p90.first((p90.count * 0.9).to_i).last
          render json: {
            ping_things: json_result,
            total_count: total_count,
            p90: p90,
            count_last_5_minutes: count_last_5_minutes,
            avg_last_5_minutes: avg_last_5_minutes
          }, status: :ok
        else
          render json: json_result
        end
      rescue ActionController::ParameterMissing
        render json: { "status" => "Parameter Missing" }, status: 400
      rescue StandardError => e
        Appsignal.send_error(e)
        render json: { "status" => e.message }, status: 500
      end

      def create
        api_token = request.headers["Token"]
        ping_thing = PingThingRaw.new(
          raw_data: ping_thing_params.to_json,
          api_token: api_token,
          network: params[:network]
        )
        if ping_thing.save
          render json: { status: "created" }, status: :created
        else
          render json: ping_thing.errors.to_json, status: :bad_request
        end
      end

      def create_batch
        api_token = request.headers["Token"]

        begin
          raise InvalidRecordCount, "Number of records exceeds #{MAX_RECORDS}" \
            if ping_thing_batch_params[:transactions].count > MAX_RECORDS

          txs = ping_thing_batch_params[:transactions].map do |tx|
            {
              raw_data: tx.to_json,
              api_token: api_token,
              network: params[:network]
            }
          end

          PingThingRaw.create! txs
          render json: { status: "created" }, status: :created
        rescue ActiveRecord::RecordInvalid, InvalidRecordCount => e
          render json: e.to_json, status: :bad_request
        end
      end

      private

      def index_params
        params.permit(:network, :limit, :page, :with_stats)
      end

      def ping_thing_params
        params.permit(
          :amount,
          :application,
          :commitment_level,
          :signature,
          :success,
          :time,
          :transaction_type,
          :reported_at
        )
      end

      def ping_thing_batch_params
        params.permit(
          transactions: [
            :amount,
            :application,
            :commitment_level,
            :signature,
            :success,
            :time,
            :transaction_type,
            :reported_at
            ]
          )

      end

      def create_json_result(ping_thing)
        hash = {}
        hash.merge!(ping_thing.to_builder.attributes!)
        hash.merge!(ping_thing.user.to_builder.attributes!)
      end
    end
  end
end
