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
        unless epoch_params[:network].present?
          render(json: { 'status' => 'Parameter Missing' }, status: 400)
        end
      end
    end
  end
end
