# frozen_string_literal: true

module Api
  module V1
    class GossipNodesController < BaseController
      def index
        if nodes_params.has_key? "staked"
          staked = ["true", true].include? nodes_params[:staked] ? true : false
        else
          staked = nil 
        end
        nodes = GossipNodeQuery.new(network: nodes_params[:network]).call(
          staked: nodes_params[:staked] == "true",
          per: nodes_params[:per] || 100,
          page: nodes_params[:page] || 1,
        )

        render json: nodes.to_json
      end

      private

      def nodes_params
        params.permit(:network, :staked, :per, :page)
      end
    end
  end
end
