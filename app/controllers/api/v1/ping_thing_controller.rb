module Api
  module V1
    class PingThingController < BaseController
      
      def create
        PingThingRaw.create(raw_data: ping_thing_params.to_json, token: params[:token])
        render json: {status: 'ok'}, status: :ok
      end

      private

      def ping_thing_params
        params.permit(:amount, :time, :signature, :transaction_type)
      end
    end
  end
end
