module Api
  module V1
    class PingThingController < BaseController
      
      def create
        api_token = request.headers["Token"]
        PingThingRaw.create(
          raw_data: ping_thing_params.to_json,
          token: params[:token],
          api_token: api_token,
          network: params[:network]
        )
        render json: {status: "ok"}, status: :ok
      end

      private

      def ping_thing_params
        params.permit(:amount, :time, :signature, :transaction_type)
      end
    end
  end
end
