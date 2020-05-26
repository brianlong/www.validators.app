# frozen_string_literal: true

module Api
  module V1
    # This is the V1 API controller.
    class ApiController < BaseController
      # POST api/v1/collector
      def collector
        @collector = Collector.new(
          collector_params.merge(
            user_id: User.where(api_token: request.headers['Token']).first.id,
            ip_address: request.remote_ip
          )
        )

        if @collector.save
          render json: { 'status' => 'Accepted' }, status: 202
        else
          render json: { 'status' => 'Bad Request' }, status: 400
        end
      rescue ActionController::ParameterMissing
        render json: { 'status' => 'Parameter Missing' }, status: 400
      end

      # This is a simple endpoint to test API connections.
      # GET api/v1/ping => { 'answer' => 'pong' }
      def ping
        render json: { 'answer' => 'pong' }, status: 200
      end

      # Filter params for the Collector
      def collector_params
        params.require(:collector).permit(
          :payload_type,
          :payload_version,
          :payload
        )
      end
    end
  end
end
