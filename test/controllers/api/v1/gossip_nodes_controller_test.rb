# frozen_string_literal: true

require "test_helper"

class GossipNodesControllerTest < ActionDispatch::IntegrationTest
  include ResponseHelper

  def setup
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
end
