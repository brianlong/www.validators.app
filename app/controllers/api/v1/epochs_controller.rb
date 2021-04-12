# frozen_string_literal: true

require 'appsignal'

module Api
  module V1
    # This is the V1 API controller.
    class EpochsController < BaseController
      before_action :ensure_params

      # GET last/current epoch
      def last
        @epoch = EpochWallClock.last_by_network(epoch_params[:network])
      rescue StandardError => e
        Appsignal.send_error(e)
        render json: { 'status' => e.message }, status: 500
      end

      #GET list of all epochs
      def index
        @epoch_list = EpochWallClock.by_network(epoch_params[:network])
      rescue StandardError => e
        Appsignal.send_error(e)
        render json: { 'status' => e.message }, status: 500
      end

      private

      def epoch_params
        params.permit(:network)
      end

      def ensure_params
        render(json: { 'status' => 'Parameter Missing' }, status: 400) unless epoch_params['network']
      end
    end
  end
end
