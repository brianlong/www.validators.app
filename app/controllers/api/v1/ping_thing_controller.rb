module Api
  module V1
    class PingThingsController < BaseController
      
      def create
        api_token = request.headers["Token"]
        ping_thing = PingThingRaw.new(
          raw_data: ping_thing_params.to_json,
          token: params[:token],
          api_token: api_token,
          network: params[:network]
        )
        if ping_thing.save
          render json: { status: "ok" }, status: :created
        else
          render json: ping_thing.errors.to_json, status: 400
        end
      end

      private

      def ping_thing_params
        params.permit(:amount, :time, :signature, :transaction_type)
      end
    end
  end
end
