# frozen_string_literal: true

module Api
  module V1
    class AlpenglowStatsController < BaseController
      before_action :ensure_network

      def cluster
        query = AlpenglowClusterStatsQuery.new(network: stats_params[:network], epoch: stats_params[:epoch])

        render json: { epochs: query.epochs, cluster_stats: query.call }, status: :ok
      end

      def validators
        epoch = AlpenglowClusterStatsQuery.new(network: stats_params[:network], epoch: stats_params[:epoch]).selected_epoch
        return render(json: { epoch: nil, total_count: 0, validators: [] }, status: :ok) if epoch.nil?

        result = AlpenglowValidatorStatsQuery.new(
          network: stats_params[:network],
          epoch: epoch,
          sort_by: stats_params[:sort_by],
          direction: stats_params[:direction],
          page: stats_params[:page] || 1,
          per: stats_params[:per] || AlpenglowValidatorStatsQuery::PER_PAGE
        ).call

        render json: result, status: :ok
      end

      private

      def stats_params
        params.permit(:network, :epoch, :sort_by, :direction, :page, :per)
      end

      def ensure_network
        render json: { "status" => "Invalid network" }, status: 400 unless NETWORKS.include?(stats_params[:network])
      end
    end
  end
end
