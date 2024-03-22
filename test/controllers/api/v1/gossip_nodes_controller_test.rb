# frozen_string_literal: true

require "test_helper"

module Api
  module V1
    class GossipNodesControllerTest < ActionDispatch::IntegrationTest
      include ResponseHelper
    
      setup do
        @network = "testnet"
    
        @user = create(:user)
        @headers = { "Token" => @user.api_token }
        @gossip_nodes = create_list(:gossip_node, 60)
      end
    
      test "GET api_v1_gossip_nodes without token returns error" do
        get api_v1_gossip_nodes_path(network: @network)
        assert_response 401
        expected_response = { "error" => "Unauthorized" }
    
        assert_equal expected_response, response_to_json(@response.body)
      end
    
      test "GET api_v1_gossip_nodes with token returns 200" do
        get api_v1_gossip_nodes_path(network: @network), headers: @headers
    
        assert_response 200
        assert_equal 60, response_to_json(@response.body).size
      end
    
      test "GET api_v1_gossip_nodes returns only active nodes" do
        inactive_node = create(:gossip_node, :inactive)
        get api_v1_gossip_nodes_path(network: @network), headers: @headers
    
        assert_response 200
        api_nodes = response_to_json(@response.body)
        refute api_nodes.include?(inactive_node)
      end
    
      test "GET api_v1_gossip_nodes with token as csv returns 200" do
        path = api_v1_gossip_nodes_path(network: @network) + ".csv"
        get path, headers: @headers
    
        assert_response :success
        assert_equal "text/csv", response.content_type
        csv = CSV.parse response.body # Let raise if invalid CSV
        assert csv
        assert_equal csv.size, 61
    
        headers = (
          GossipNode::API_FIELDS +
          GossipNode::API_VALIDATOR_FIELDS +
          GossipNode::API_DATA_CENTER_FIELDS
        ).map(&:to_s)
        assert_equal csv.first, headers
      end
    end
  end
end
