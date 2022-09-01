# frozen_string_literal: true

require 'test_helper'

# ApiControllerTest
class DataCentersControllerTest < ActionDispatch::IntegrationTest
  include ResponseHelper

  setup do
    @data_center = create(:data_center, :berlin)
    @dch = create(:data_center_host, data_center: @data_center)
    @node = create(:gossip_node, network: "testnet")
    @vip = create(:validator_ip, :active, data_center_host: @dch, address: @node.ip)

    @user = create(:user)
    @network = "testnet"
    @headers = { "Token" => @user.api_token }
  end

  test "request without token should get error" do
    get api_v1_data_centers_with_nodes_url(network: @network)
    assert_response 401
    expected_response = { "error" => "Unauthorized"  }

    assert_equal expected_response, response_to_json(@response.body)
  end

  test "request with token should succeed" do
    get api_v1_data_centers_with_nodes_url(network: @network), headers: @headers
    assert_response 200
  end

  test "response has correct fields" do
    get api_v1_data_centers_with_nodes_url(network: @network), headers: @headers
    resp = response_to_json(@response.body)

    assert_response 200
    assert_equal %w[
      autonomous_system_number
      data_center_key
      latitude
      longitude
      country_name
      nodes_count
      validators_count
    ].sort, resp[0].keys.sort
  end
end
