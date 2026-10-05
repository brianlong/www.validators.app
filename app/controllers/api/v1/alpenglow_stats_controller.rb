# frozen_string_literal: true

module Api
  module V1
    class AlpenglowStatsController < BaseController
      before_action :ensure_network

      def cluster
        query = AlpenglowClusterStatsQuery.new(network: stats_params[:network], epoch: stats_params[:epoch])

        render json: { epochs: query.epochs, cluster_stats: query.call }, status: :ok
      end

      private

      def stats_params
        params.permit(:network, :epoch)
      end

      def ensure_network
        render json: { "status" => "Invalid network" }, status: 400 unless NETWORKS.include?(stats_params[:network])
      end
    end
  end
end
