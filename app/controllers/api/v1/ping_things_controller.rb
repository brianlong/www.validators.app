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
        if index_params[:time_filter]
          ping_things = ping_things.where("response_time >= ?", index_params[:time_filter].to_i)
        end
        ping_things = ping_things.page(page).per(limit)

        json_result = ping_things.map { |pt| create_json_result(pt) }

        render json: json_result, status: :ok
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
        params.permit(:network, :limit, :page, :with_stats, :time_filter)
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
          :reported_at,
          :slot_sent,
          :slot_landed
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
            :reported_at,
            :slot_sent,
            :slot_landed
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
