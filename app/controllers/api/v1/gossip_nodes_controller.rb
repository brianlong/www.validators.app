# frozen_string_literal: true

module Api
  module V1
    class GossipNodesController < BaseController
      NODES_DEFAULT_LIMIT = 100
      NODES_DEFAULT_PAGE = 1

      def index
        staked = if nodes_params.has_key? "staked"
          ["true", true].include? nodes_params[:staked] ? true : false
        else
          nil 
        end
        
        nodes = GossipNodeQuery.new(network: nodes_params[:network]).call(
          staked: staked,
          per: nodes_params[:per] || NODES_DEFAULT_LIMIT,
          page: nodes_params[:page] || NODES_DEFAULT_PAGE,
        )

        render json: nodes.as_json(except: [:id])
      end

      private

      def nodes_params
        params.permit(:network, :staked, :per, :page)
      end
    end
  end
end
