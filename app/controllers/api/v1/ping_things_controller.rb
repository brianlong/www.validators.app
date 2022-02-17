# frozen_string_literal: true

module Api
  module V1
    class PingThingsController < BaseController

      class InvalidRecordCount < StandardError; end
      
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
        max_records = 50
        api_token = request.headers["Token"]

        begin
          raise InvalidRecordCount, "Number of records exceeds #{max_records}" \
            if ping_thing_batch_params[:transactions].count > max_records

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

      def ping_thing_params
        params.permit(:amount, :time, :signature, :transaction_type, :reported_at)
      end

      def ping_thing_batch_params
        params.permit(transactions: [:amount, :time, :signature, :transaction_type, :reported_at])
      end
    end
  end
end
