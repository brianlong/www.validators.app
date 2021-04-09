# frozen_string_literal: true

require 'appsignal'

module Api
  module V1
    # This is the V1 API controller.
    class EpochsController < BaseController
      # GET last/current epoch
      def last
        @epoch = EpochWallClock.last_by_network(epoch_params[:network])
        render(json: { 'status' => 'Parameter Missing' }, status: 400) unless epoch_params['network']
      end

      def all
        @epoch_list = EpochWallClock.by_network(epoch_params[:network])
        render(json: { 'status' => 'Parameter Missing' }, status: 400) unless epoch_params['network']
      end

      private

      def epoch_params
        params.permit(:network)
      end
    end
  end
end
