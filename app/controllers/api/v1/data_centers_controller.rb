# frozen_string_literal: true

module Api
  module V1
    class DataCentersController < BaseController
      def index_with_nodes
        data_centers = DataCenter.includes(:data_center_stats)
                                
        data_centers_formatted = data_centers.map do |dc|
          dc.to_builder(map_data: true, network: dc_params[:network]).attributes! 
        end
        
        render json: data_centers_formatted.to_json
      end

      private

      def dc_params
        params.permit(:network)
      end
    end
  end
end
