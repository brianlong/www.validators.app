# frozen_string_literal: true

module Api
  module V1
    class ClusterStatsController < BaseController
      def last
        network = params[:network]
        total_active_stake = ClusterStat.by_network(network).last.total_active_stake

        render json: { total_active_stake: total_active_stake }, status: :ok
      end
    end
  end
end
