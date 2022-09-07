# frozen_string_literal: true

require "test_helper"

# ApiControllerTest
class DataCentersControllerTest < ActionDispatch::IntegrationTest
  include ResponseHelper

  setup do
    @network = "testnet"
    @data_center = create(:data_center, :berlin)
    data_center_stats = create(
      :data_center_stat,
      data_center:@data_center,
      network: @network,
      gossip_nodes_count: 1,
      validators_count: 1
    )

    @user = create(:user)
    @headers = { "Token" => @user.api_token }
  end

  test "#data_centers_with_nodes request without token returns error" do
    get api_v1_data_centers_with_nodes_url(network: @network)
    assert_response 401
    expected_response = { "error" => "Unauthorized"  }

    assert_equal expected_response, response_to_json(@response.body)
  end

  test "#data_centers_with_nodes request with token returns success" do
    get api_v1_data_centers_with_nodes_url(network: @network), headers: @headers
    assert_response 200
  end

  test "#data_centers_with_nodes response has correct fields" do
    get api_v1_data_centers_with_nodes_url(network: @network), headers: @headers
    resp = response_to_json(@response.body)

    fields = (DataCenter::FIELDS_FOR_GOSSIP_NODES + DataCenterStat::FIELDS_FOR_API).map{ |f| f.split(" ")[-1] }
    assert_response 200
    assert_equal fields.sort, resp[0].keys.sort
  end

  test "#data_centers_with_nodes response has no data_centers with 0 nodes" do
    empty_dc = create(:data_center)
    data_center_stats = create(
      :data_center_stat,
      data_center: empty_dc,
      network: @network,
      gossip_nodes_count: 0,
      validators_count: 0
    )

    get api_v1_data_centers_with_nodes_url(network: @network), headers: @headers
    resp = JSON.parse(@response.body)

    assert_response 200
    assert_equal 1, resp.size
    assert_equal 1, resp.first["gossip_nodes_count"]
    assert_equal 1, resp.first["validators_count"]
  end
end
