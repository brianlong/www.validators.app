# frozen_string_literal: true

module Api
  module V1
    class GossipNodesController < BaseController
      def index
        nodes = GossipNodeQuery.new(network: nodes_params[:network]).call

        render json: nodes.to_json
      end

      private

      def nodes_params
        params.permit(:network, :per, :page)
      end
    end
  end
end
