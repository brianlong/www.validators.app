module Api
  module V1
    class StakePoolsController < BaseController
      def index
        @stake_pools = StakePool.where(network: params[:network])
      end

      private

      def index_params
        params.permit(:network)
      end
    end
  end
end
