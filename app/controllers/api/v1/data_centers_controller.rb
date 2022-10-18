# frozen_string_literal: true

module Api
  module V1
    class DataCentersController < BaseController
      def index_with_nodes
        show_gossip_nodes = dc_params[:show_gossip_nodes] == "false" ? false : true

        fields_dc = DataCenter::FIELDS_FOR_GOSSIP_NODES.map do |field|
          "data_centers.#{field}"
        end
        fields_stats = DataCenterStat::FIELDS_FOR_API.map do |field|
          "data_center_stats.#{field}"
        end
        fields_stats.delete("data_center_stats.active_gossip_nodes_count") unless show_gossip_nodes

        merged_fields = (fields_dc + fields_stats).join(", ")

        query = if show_gossip_nodes
                  "data_center_stats.active_gossip_nodes_count > 0
                  OR data_center_stats.active_validators_count > 0"
                else
                  "data_center_stats.active_validators_count > 0"
                end

        data_centers = DataCenter.select(merged_fields)
                                 .joins(:data_center_stats)
                                 .where.not(data_center_key: "0--Unknown")
                                 .where("data_center_stats.network = ?", dc_params[:network])
                                 .where(query)
                                 .order(:validators_count)

        render json: {
          data_centers: data_centers
        }, status: :ok
      end

      private

      def dc_params
        params.permit(:network, :show_gossip_nodes)
      end
    end
  end
end
