# frozen_string_literal: true

module Api
  module V1
    class GossipNodesController < BaseController
      NODES_DEFAULT_LIMIT = 100
      NODES_DEFAULT_PAGE = 1

      def index
        staked = if nodes_params.has_key? "staked"
          ["true", true].include? nodes_params[:staked]
        else
          nil 
        end
        
        nodes = GossipNodeQuery.new(network: nodes_params[:network]).call(
          staked: staked,
          per: nodes_params[:per] || NODES_DEFAULT_LIMIT,
          page: nodes_params[:page] || NODES_DEFAULT_PAGE,
        )

        respond_to do |format|
          format.json { render json: nodes.as_json(except: [:id]) }
          format.csv do
            send_data convert_to_csv(index_csv_headers, nodes.as_json),
                      filename: "gossip-nodes-#{DateTime.now.strftime("%d%m%Y%H%M")}.csv"
          end
        end
        
      end

      private

      def index_csv_headers
        GossipNode.column_names.reject{ |c| c == "id" }
      end

      def nodes_params
        params.permit(:network, :staked, :per, :page)
      end
    end
  end
end
