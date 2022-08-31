# frozen_string_literal: true

module Api
  module V1
    class DataCentersController < BaseController
      def index_with_nodes
        results = DataCenter.select("
          data_centers.data_center_key,
          data_centers.location_latitude,
          data_centers.location_longitude,
          data_centers.city_name,
          COUNT(gossip_nodes.id) as nodes_count
        ").left_outer_joins(:gossip_nodes)
          .where("gossip_nodes.network = :network", network: dc_params[:network])
          .group("data_centers.id")
          
        render json: results.to_json(except: [:id])
      end

      private

      def dc_params
        params.permit(:network)
      end
    end
  end
end
