# frozen_string_literal: true

# curl -H "Token: secret-api-token" https://localhost:3000/api/v1/validators/:network
require 'appsignal'

module Api
  module V1
    # This is the V1 API controller.
    class ApiController < BaseController
      include CollectorLogic
      include ActionController::ImplicitRender

      # POST api/v1/collector
      def collector
        render json: { 'status' => 'Method Gone' }, status: 410
      end

      # This is a simple endpoint to test API connections.
      # GET api/v1/ping => { 'answer' => 'pong' }
      def ping
        render json: { 'answer' => 'pong' }, status: 200
      end

      def ping_times
        render json: { 'status' => 'Method Gone' }, status: 410
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
