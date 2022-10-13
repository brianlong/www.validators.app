# frozen_string_literal: true

module Api
  module V1
    class DataCentersController < BaseController
      def index_with_nodes
        fields_dc = DataCenter::FIELDS_FOR_GOSSIP_NODES.map do |field|
          "data_centers.#{field}"
        end

        fields_stats = DataCenterStat::FIELDS_FOR_API.map do |field|
          "data_center_stats.#{field}"
        end

        merged_fields = (fields_dc + fields_stats).join(", ")

        data_centers = DataCenter.select(merged_fields)
                                 .joins(:data_center_stats)
                                 .where.not(data_center_key: "0--Unknown")
                                 .where(
                                   "data_center_stats.network = ?
                                   AND (
                                     data_center_stats.active_gossip_nodes_count > 0
                                     OR data_center_stats.active_validators_count > 0
                                   )",
                                   dc_params[:network]
                                 ).order(:validators_count)

        render json: {
          data_centers: data_centers
        }, status: :ok
      end

      private

      def dc_params
        params.permit(:network)
      end
    end
  end
end
