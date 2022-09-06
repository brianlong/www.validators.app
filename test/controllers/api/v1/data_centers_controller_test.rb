# frozen_string_literal: true

require "test_helper"

# ApiControllerTest
class DataCentersControllerTest < ActionDispatch::IntegrationTest
  include ResponseHelper

  setup do
    @network = "testnet"
    @data_center = create(:data_center, :berlin)
    data_center_stats = create(:data_center_stat, data_center: @data_center, network: @network)

    @user = create(:user)
    @headers = { "Token" => @user.api_token }
  end

  test "request without token returns error" do
    get api_v1_data_centers_with_nodes_url(network: @network)
    assert_response 401
    expected_response = { "error" => "Unauthorized"  }

    assert_equal expected_response, response_to_json(@response.body)
  end

  test "request with token returns success" do
    get api_v1_data_centers_with_nodes_url(network: @network), headers: @headers
    assert_response 200
  end

  test "response has correct fields" do
    get api_v1_data_centers_with_nodes_url(network: @network), headers: @headers
    resp = response_to_json(@response.body)

    fields = (DataCenter::FIELDS_FOR_GOSSIP_NODES + DataCenterStat::FIELDS_FOR_API).map{ |f| f.split(" ")[-1] }
    assert_response 200
    assert_equal fields.sort, resp[0].keys.sort
  end
end
