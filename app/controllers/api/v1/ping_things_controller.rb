# frozen_string_literal: true

module Api
  module V1
    class PingThingsController < BaseController

      def index
        limit = [(index_params[:limit] || 240).to_i, 11520].min
        ping_things = PingThing.where(network: index_params[:network])
                               .includes(:user)
                               .last(limit)
        json_result = ping_things.map { |pt| create_json_result(pt) }
        render json: json_result
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

      private

      def index_params
        params.permit(:network, :limit)
      end

      def ping_thing_params
        params.permit(:amount, :time, :signature, :transaction_type)
      end

      def create_json_result(ping_thing)
        hash = {}
        hash.merge!(ping_thing.to_builder.attributes!)
        hash.merge!(ping_thing.user.to_builder.attributes!)
      end
    end
  end
end
