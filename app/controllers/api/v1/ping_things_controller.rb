module Api
  module V1
    class PingThingsController < BaseController
      
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

      def ping_thing_params
        params.permit(:amount, :time, :signature, :transaction_type)
      end
    end
  end
end
