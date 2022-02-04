module Api
  module V1
    class PingThingController < BaseController
      
      def create
        PingThingRaw.create(raw_data: ping_thing_params.to_json, token: params[:token])
        render json: {status: 'ok'}, status: :ok
      end

      private

      def ping_thing_params
        params.require(:ping_thing).permit!
      end
    end
  end
end
