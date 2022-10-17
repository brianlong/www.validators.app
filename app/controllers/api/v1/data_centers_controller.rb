# frozen_string_literal: true

module Api
  module V1
    class DataCentersController < BaseController
      def index_with_nodes
        fields_dc = DataCenter::FIELDS_FOR_GOSSIP_NODES.map do |field|
          "data_centers.#{field}"
        end

        fields_stats = if params[:hide_gossip_nodes] == "true"
                         ["data_center_stats.active_validators_count"]
                       else
                         DataCenterStat::FIELDS_FOR_API.map { |field| "data_center_stats.#{field}" }
                       end

        merged_fields = (fields_dc + fields_stats).join(", ")

        query = if params[:hide_gossip_nodes] == "true"
                  "data_center_stats.network = ?
                   AND (data_center_stats.active_validators_count > 0)"
                else
                  "data_center_stats.network = ?
                   AND (
                     data_center_stats.active_gossip_nodes_count > 0
                     OR data_center_stats.active_validators_count > 0
                   )"
                end

        data_centers = DataCenter.select(merged_fields)
                                 .joins(:data_center_stats)
                                 .where.not(data_center_key: "0--Unknown")
                                 .where(query, dc_params[:network])
                                 .order(:validators_count)

        render json: {
          data_centers: data_centers
        }, status: :ok
      end

      private

      def dc_params
        params.permit(:network, :hide_gossip_nodes)
      end
    end
  end
end
