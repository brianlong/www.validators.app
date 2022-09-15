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
                                 .where(
                                   "data_center_stats.network = ?
                                   AND (
                                     data_center_stats.gossip_nodes_count > 0
                                     OR data_center_stats.validators_count > 0
                                   )",
                                   dc_params[:network]
                                 ).order(:validators_count)

        total_validators_count = data_centers.sum{ |dc| dc[:validators_count] }
        total_nodes_count = data_centers.sum{ |dc| dc[:gossip_nodes_count] }

        render json: {
          data_centers: data_centers,
          total_validators_count: total_validators_count,
          total_nodes_count: total_nodes_count
        }, status: :ok
      end

      private

      def dc_params
        params.permit(:network)
      end
    end
  end
end
