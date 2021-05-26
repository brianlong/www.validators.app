# frozen_string_literal: true

module Api
  module V1
    class EpochsController < BaseController
      before_action :ensure_params

      #GET list of all epochs
      def index
        @epoch_list = EpochWallClock.by_network(epoch_params[:network])
                                    .page(epoch_params[:page])
                                    .per(epoch_params[:per])
        @total = EpochWallClock.by_network(epoch_params[:network]).count
      end

      private

      def epoch_params
        params.permit(:network, :per, :page)
      end

      def ensure_params
        render(json: { 'status' => 'Parameter Missing' }, status: 400) \
          unless epoch_params[:network].present?
        render(json: { 'status' => 'maximum value for per is 500' }, status: 400) \
          if epoch_params[:per] && epoch_params[:per].to_i > 500
      end
    end
  end
end
